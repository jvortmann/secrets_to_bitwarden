require 'nokogiri'
require 'csv'

input_file = ARGV[0]
output_file = ARGV[1]


credentials = Nokogiri::XML(File.open(input_file)).css("credential")

translate = {
  "name" => "name",
  "login_username" => "identifier",
  "login_password" => "secret secretValue",
  "login_uri" => "service address",
  "notes" => "notes"
}

fetch = ->(credential, from) do
  credential.css(from).empty? ? '' : credential.css(from)[0].content
end

credential_to_login = ->(credential) do
  translate.map do |to, from|
    [to, fetch.call(credential, from)]
  end.to_h
end

logins = credentials.map(&credential_to_login)

CSV.open(output_file, "wb") do |csv|
  csv << %W[folder favorite type name notes fields login_uri login_username login_password login_totp]
  logins.each do |login|
    csv << ['',0,'login',login["name"],login["notes"],'',login["login_uri"],login["login_username"],login["login_password"],'']
  end
end
