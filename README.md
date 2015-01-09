# LeadScore

This library calculates a 'lead score', a simple score which gives you some indication that an email address is either associated with an influential individual, or a high profile company.

This score is especially useful for sales and marketing. For example, you could calculate scores for all your inbound sales inquires and also for existing customers, providing a good signal for valuable leads.

Behind the scenes, this library uses [Clearbit](https://clearbit.co), a data API which returns information on email addresses and company domain names. That information is then [used to calculate](https://github.com/maccman/clearbit-lead_score/blob/master/lib/clearbit/lead_score.rb#L53) a (fairly rudimentary) score taking into account such things as how many Twitter followers the person has, or if how much the company has raised, how many employees it has, etc.

Scores are out of `1.0`, where `1.0` is the highest and `0.0` the lowest (we didn't find any information).

## Getting started

Firstly you'll need an [Clearbit](https://clearbit.co) API key - register there and save your key. Clearbit provides 50 free lookups a month.

Then install the gem, `clearbit-leadscore`. A CLI is provided for simple email lookups.

    gem install clearbit-leadscore

    $ clearbit-leadscore
      Usage: clearbit-leadscore [options] email
          -k, --api-key                    Set API Key
          -h, --help                       Display this screen


    clearbit-leadscore --api-key CLEARBIT_KEY alex@alexmaccaw.com

There's also a Ruby API.

    Clearbit::LeadScore.key = ENV['CLEARBIT_KEY']

    result = Clearbit::LeadScore.lookup(email)

    if result
      puts "Name: #{result.person.try(:name)}"
      puts "Company name: #{result.company.try(:name)}"

      if result.score > 0.5
        puts "Baller"
      end
    else
      puts "Person or company not found"
    end


## Method: `lookup(email, options)`

As well as just passing an email, there are a number of additional options you can send to `Clearbit::LeadScore.lookup`, such as the weights that are used internally. You could also just use the information returned to calculate your own score.

This method uses the [Clearbit Streaming API](https://clearbit.com/docs#streaming) which is especially useful if you're making long-lived requests (i.e. you’re making requests to Clearbit from a messaging queue).

This method returns a hash with **both** person and company data, assuming data for both are available. Otherwise, `result.person` or `result.company` will return `nil`

The default options are:

    {
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
    }
