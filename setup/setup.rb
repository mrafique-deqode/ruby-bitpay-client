$LOAD_PATH.unshift '/home/deq/Documents/ruby-bitpay-keyutils/ruby-bitpay-keyutils/lib'
require 'bitpay_keyutils'
$LOAD_PATH.unshift '/home/deq/Documents/ruby-bitpay-sdk/ruby-bitpay-client/lib'
require 'bitpay_client'

$environment = ''
$key = ''
$client = ''
$domain = ''
$insecure = ''
$pairing_code = ''
$facade = ''
$req_merchant = ''
$req_payout = ''

puts 'Select target environment'
puts 'Press T for testing or P for production'

$answer = gets.chomp.downcase

def select_env
    case $answer
    when 't'
        $environment = 'test'
        $domain = 'https://test.bitpay.com'
        $insecure = true
        # puts $environment
    when 'p'
        $environment = 'production'
        $domain = 'https://bitpay.com'
        $insecure = false
        # puts $environment
    else
        puts 'nothing selected or wrong option entered, please restart setup script and select proper option'
        # select_env()
    end
end

def generate_new_key
    begin
        $key = Bitpay::RubyKeyutils.generate_pem
        puts 'new private key generated: ' + $key
    rescue => e
        puts e
    ensure
        
    end
end

def initiate_client
    $client = Bitpay::RubyClient.new(api_uri: $domain, pem: $key, insecure: $insecure)
    puts $client
    
end

def get_pairing_code
    $pairing_code = $client.pair_client()
    puts $pairing_code.dig("data", 0, "pairingCode")
    puts 'Pairing code generated. Please verify it by going on ' + $domain
end


def select_facade
    case $facade
    when 'm'
        puts 'Requesting tokens....'
        sleep 1
    when 'p'
        puts 'Requesting tokens....'
        sleep 1
    else
        puts 'Requesting tokens....'
        sleep 1
    end
end

def request_tokens
    $req_merchant = false
    $req_payout = false
    begin
        case $facade
        when 'm'
            $req_merchant = true
            $req_payout = false
        when 'p'
            $req_payout = true
            $req_merchant = false
        else
            $req_merchant = true
            $req_payout = true
        end
    rescue => exception
        puts exception
    ensure
        
    end
end

select_env()
puts $environment + ' environment selected'
puts 'generating new key'
sleep 2
generate_new_key()
puts 'Key generated'
sleep 1
puts 'Initiating client.....'
sleep 2
initiate_client()
puts 'Client initiated'
sleep 2
puts 'Selct tokens that you would like to request'
puts 'Press M for merchant, P for payout, or B for both'
$facade = gets.chomp.downcase
sleep 1
select_facade()
sleep 2
puts 'Generating pairing code for ' + $facade
sleep 2
get_pairing_code()
sleep 2