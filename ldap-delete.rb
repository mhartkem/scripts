require 'rubygems'
require 'net-ldap'

ldap = Net::LDAP.new :host => "127.0.0.1",
  :port => 389,
  :auth => {
    :method => :simple,
    :username => "cn=admin,dc=example,dc=com",
    :password => "Password1"
  }

print "Enter the common name of a user to delete: "
cn = gets.chomp

dn = "cn=" + cn + ",ou=users,dc=example,dc=com"

ldap.delete( :dn => dn )
puts ldap.get_operation_result.message

