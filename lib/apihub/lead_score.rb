require "apihub"
require "apihub/lead_score/version"
require "apihub/lead_score/email_providers"

module APIHub
  module LeadScore extend self
    include APIHub

    attr_accessor :defaults

    self.defaults = Mash.new({
      twitter_followers_weight:   0.05,
      angellist_followers_weight: 0.05,
      klout_score_weight:         0.05,
      company_twitter_followers_weight: 0.05,
      company_alexa_rank_weight:  0.000005,
      company_google_rank_weight: 0.05,
      company_employees_weight:   0.5,
      company_raised_weight:      0.0000005,
      company_score:              10,
      total_score:                1415
    })

    def api_key=(value)
      APIHub.api_key = value
    end

    def baller?(email, options = {})
      threshold = options[:threshold] || 20

      lookup(options).score > threshold
    end

    def lookup(email)
      if email =~ /.+@.+/
        person = Streaming::Person[email: email]
        suffix, domain = email.split('@', 2)

      else
        domain = email
      end

      unless EmailProviders::DOMAINS.include?(domain)
        company = Streaming::Company[domain: domain]
      end

      return unless person || company

      result = Mash.new(person || {})
      result.merge!(company: company)
      result.merge!(score: score(result))
      result
    end

    def score(result, options = {})
      options = defaults.merge(options)

      score = 0.0

      return score unless result

      if result.avatar
        score += 5
      end

      if result.twitter
        score += result.twitter.followers * options.twitter_followers_weight
      end

      if result.angellist
        score += result.angellist.followers * options.angellist_followers_weight
      end

      if result.klout && result.klout.score
        score += result.klout.score * options.klout_score_weight
      end

      if company = result.company
        unless company.personal
          score += options.company_score
        end

        if company.raised
          score += company.raised *
                    options.company_raised_weight
        end

        if company.employees
          score += company.employees *
                    options.company_employees_weight
        end

        if company.alexa && company.alexa.globalRank
          score += 1 / (company.alexa.globalRank *
                    options.company_alexa_rank_weight)
        end

        if company.google && company.google.rank && company.google.rank > 0
          score += 1 / (company.google.rank *
                    options.company_google_rank_weight)
        end

        if company.twitter
          score += company.twitter.followers *
                    options.company_twitter_followers_weight
        end
      end

      score /= options.total_score

      [score.round(1), 1.0].min
    end
  end
end