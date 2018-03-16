require 'rubygems'
require 'net-ldap'

ldap = Net::LDAP.new :host => "127.0.0.1",
  :port => 389,
  :auth => {
    :method => :simple,
    :username => "cn=admin,dc=example,dc=com",
    :password => "Password1"
  }

print "Enter the first name of a user to add: "
first_name = gets.chomp
givenName = first_name

print "Enter the last name of a user to add: "
last_name = gets.chomp
sn = last_name

cn = first_name + " " + last_name
userPassword = "Example1"
uid = first_name[0,1].downcase + last_name.downcase
mail = first_name.downcase + "_" + last_name.downcase + "@example.com"

dn = "cn=" + cn + ",ou=users,dc=example,dc=com"
attr = {
  :givenName => givenName,
  :sn => sn,
  :cn => cn,
  :userPassword => userPassword,
  :uid => uid,
  :mail => mail,
  :objectclass => ["inetOrgPerson"]
}

ldap.add( :dn => dn, :attributes => attr )
puts ldap.get_operation_result.message

# below is for duplicate entries (users with the same name)
cn_suffix = 2
uid_suffix = 2
mail_suffix = 2

while ldap.get_operation_result.message == "Entry Already Exists"
  cn = first_name + " " + last_name + cn_suffix.to_s
  uid = first_name[0,1].downcase + last_name.downcase + uid_suffix.to_s
  mail = first_name.downcase + "_" + last_name.downcase + mail_suffix.to_s + "@example.com"
  dn = "cn=" + cn + ",ou=users,dc=example,dc=com"
  attr = {
    :givenName => givenName,
    :sn => sn,
    :cn => cn,
    :userPassword => userPassword,
    :uid => uid,
    :mail => mail,
    :objectclass => ["inetOrgPerson"]
  }
  ldap.add( :dn => dn, :attributes => attr )
  puts ldap.get_operation_result.message
  cn_suffix += 1
  uid_suffix += 1
  mail_suffix += 1
end

