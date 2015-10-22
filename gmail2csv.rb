require 'rubygems'
require 'bundler/setup'

require 'highline/import'
require 'gmail'
require 'csv'
require 'ruby-progressbar'

username = ask('Username: ')
password = ask('Password: ') { |q| q.echo = '*' }

Gmail.new(username, password) do |gmail|
  choose do |menu|
    menu.prompt = 'Choose mailbox:'

    gmail.mailbox_list.each do |mailbox|
      name = Net::IMAP.decode_utf7(mailbox.name)
      menu.choice(name) {
        total = gmail.label(mailbox.name).emails.count
        say("Total: #{total}")

        bar = ProgressBar.create(title: "Mails", total: total, output: $stderr, format: '%a(%e) |%b>>%i| %p%%')

        filename = File.basename(name) + ".csv"
        CSV.open(filename, "w") do |csv|
          gmail.label(mailbox.name).emails.each do  |email|
            to = email.to.join if email.to
            csv << [ email.subject, to, email.date ]
            bar.increment
          end
        end
      }
    end
  end
end
