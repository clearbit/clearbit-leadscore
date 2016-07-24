module Clearbit
  module LeadScore
    module Score extend self
      attr_accessor :defaults

      self.defaults = Mash.new({
        twitter_followers_weight:   0.09,
        angellist_followers_weight: 0.05,
        klout_score_weight:         0.05,
        company_twitter_followers_weight: 0.05,
        company_alexa_rank_weight:  0.000005,
        company_google_rank_weight: 0.05,
        company_employees_weight:   0.5,
        company_raised_weight:      0.00005,
        company_score:              10,
        total_score:                1415
      })

      def calculate(result, options = {})
        options = defaults.merge(options)

        score = 0.0

        return score unless result

        if person = result.person
          if person.avatar
            score += 5
          end

          if person.twitter.followers
            score += person.twitter.followers * options.twitter_followers_weight
          end

          if person.angellist and person.angellist.followers
            score += person.angellist.followers * options.angellist_followers_weight
          end

          if person.klout and person.klout.score
            score += person.klout.score * options.klout_score_weight
          end
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

          if company.alexa and company.alexa.globalRank
            score += 1 / (company.alexa.globalRank *
                      options.company_alexa_rank_weight)
          end

          if company.google and company.google.rank && company.google.rank > 0
            score += 1 / (company.google.rank *
                      options.company_google_rank_weight)
          end

          if company.twitter.followers
            score += company.twitter.followers *
                      options.company_twitter_followers_weight
          end
        end

        score /= options.total_score

        [score.round(1), 1.0].min
      end
    end
  end
end
