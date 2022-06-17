require './lib/bitpay_client'

class BitpaySdk

  attr_reader :environment, :private_key_path, :pem, :api_uri, :facade, :client, :merchant_token,
    :payout_token

  def initialize
    puts 'Welcome to the Bitpay API, Please make sure you have an Bitpay Account at bitpay.com'
    puts """
    Please choose the environment to proceed
    1. Test
    2. Production
    """
    @environment = gets.chomp.downcase
    sleep(2)
    set_environment
  end

  def set_environment
    set_api_uri
    generate_required_keys
  end

  def generate_required_keys
    puts "Please enter your file location for PEM key or press enter to generate a new \n"
    private_key_path = gets.chomp
    if private_key_path.empty?
      @pem = Bitpay::RubyKeyutils.generate_pem
      File.open 'private_key.pem', 'w' do |io|
        io.write pem
      end
      puts "Your PEM key generated is #{pem}"
      puts "Please save the above PEM for future use \n "
    else
      begin
        private_key_path = '/home/deq/projects/md/ruby-bitpay-client/config/bitpay_config.json'
        @pem = File.read(private_key_path)
        puts "Your PEM key fetched from above path is #{pem}"
      rescue => e
        puts e
        generate_required_keys
      end
    end

    key = Bitpay::RubyKeyutils.create_key(pem)

    puts 'Generating the Private key'
    sleep(2)
    private_key = Bitpay::RubyKeyutils.get_private_key(key)
    puts "Private key: #{private_key} \n "

    puts 'Generating the Public key'
    sleep(2)
    public_key = Bitpay::RubyKeyutils.get_public_key(key)
    puts "Public key: #{public_key} \n "

    initiate_client
    authenticate_token
    create_config_file
  end

  def initiate_client
    sleep(2)
    @client = Bitpay::RubyClient.new(api_uri: api_uri, pem: pem, insecure: true)
  end

  def set_api_uri
    @api_uri = environment == 'test' ? ENV['TEST_API_URI'] : ENV['API_URI']
  end

  def authenticate_token
    puts """Please enter the mode to Authenticate the token with your Bitpay account
    1. Client side (enter 1)
    2. Server side (enter 2) - Only used to authenticate a token for POS
    """
    authentication_mode = gets.chomp
    if authentication_mode == '1'
      puts 'We would generate the pairing code to autheticate the token with account'
      set_facade
      if %w[merchant payout both].include?(facade)
        generate_pairing_code
      else
        puts 'Please choose the correct option for facade'
        set_facade
      end
    elsif authentication_mode == '2'
      puts "Please visit the link '#{api_uri}/dashboard/merchant/api-tokens' to generate the api token \n "
      puts 'Please enter the pairing code generated above'
      pairing_code = gets.chomp
      client.pair_client(pairingCode: pairing_code)
    else
      puts 'Please choose the correct mode'
      authenticate_token
    end
  end

  def set_facade
    puts """Please enter the facade for which you want to generate the pairing code.
    1. merchant
    2. payout
    3. both (If you want to generate the pairing code for both the facades)
    """
    @facade = gets.chomp.downcase
  end

  def generate_pairing_code
    if ['merchant', 'both'].include?(facade)
      response = client.pair_client(facade: 'merchant')

      merchant_pairing_code = response["data"][0]["pairingCode"]
      puts "pairingCode for Merchant is #{merchant_pairing_code}. Please approve from the Bitpay account"
      @merchant_token = response["data"][0]["token"]
      puts "Token for Merchant is #{merchant_token} \n "
    end
    if ['payout', 'both'].include?(facade)
      response = client.pair_client(facade: 'payout')

      payout_pairing_code = response["data"][0]["pairingCode"]
      puts "pairingCode for Payout is #{payout_pairing_code}. Please approve from the Bitpay account"
      @payout_token = response["data"][0]["token"]
      puts "Token for Payout is #{payout_token} \n "
    end
    puts "Please use the PairingCode to approve token on the link '#{api_uri}/dashboard/merchant/api-tokens'\n "
  rescue => e
    puts e
  end

  def create_config_file
    config = {
      'BitPayConfiguration': {
        'Environment': environment,
        'EnvConfig': {
          'environment': {
            'PrivateKeyPath': private_key_path,
            'PrivateKey': pem,
            'ApiTokens': {
                'merchant': merchant_token,
                'payout': payout_token,
            }
          }
        }
      }
    }
    File.open("#{Dir.pwd}/config/bitpay_config.json", 'w') { |file| file.write config.to_json }
    puts "The config file is created at path #{Dir.pwd}/config/bitpay_config.json"
  end

end

BitpaySdk.new
