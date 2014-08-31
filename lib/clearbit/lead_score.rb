require "clearbit"
require "clearbit/lead_score/version"

require "clearbit/lead_score/async"
require "clearbit/lead_score/email_providers"
require "clearbit/lead_score/score"

module Clearbit
  module LeadScore extend self
    include Clearbit

    def api_key=(value)
      Clearbit.api_key = value
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