require "apihub"
require "apihub/lead_score/version"

require "apihub/lead_score/async"
require "apihub/lead_score/email_providers"
require "apihub/lead_score/score"

module APIHub
  module LeadScore extend self
    include APIHub

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

      result = Mash.new(
        person:  person,
        company: company
      )

      result.merge!(
        score: Score.calculate(result)
      )

      result
    end
  end
end