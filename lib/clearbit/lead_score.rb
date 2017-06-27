require "clearbit"
require "clearbit/lead_score/version"

require "clearbit/lead_score/async"
require "clearbit/lead_score/email_providers"
require "clearbit/lead_score/score"

module Clearbit
  module LeadScore extend self
    include Clearbit

    def key=(value)
      Clearbit.key = value
    end

    def baller?(email, threshold = 0.7)
      score(email) > threshold
    end

    def score(email)
      result = lookup(email)
      result && result.score || 0
    end

    def lookup(email)
      if email =~ /.+@.+/
        person  = Clearbit::Enrichment::Person.find(email: email, stream: true)

        if person && person.company && person.company != {}
          company = person.delete(:company)
        end

        suffix, domain = email.split('@', 2)

      else
        domain = email
      end

      unless EmailProviders::DOMAINS.include?(domain)
        company ||= Clearbit::Enrichment::Company.find(domain: domain, stream: true)

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