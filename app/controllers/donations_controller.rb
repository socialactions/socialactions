class DonationsController < ApplicationController
  
  # ssl_required              :new, :create
  # filter_parameter_logging  :cardNumber
  
  before_filter             :load_action
  
  def new
    @donation = Donation.new
    @donor = Donor.new
    @credit_card = CreditCard.new
  end
  
  def create
    @donation = Donation.new(params[:donation])
    @donor = @donation.donor = Donor.new(params[:donor])
    @credit_card = @donation.credit_card = CreditCard.new(params[:credit_card])
    @donation.action = @action

    unless @donation.valid?
      return render(:action => 'new')
    end

    # TODO: encapsulate this in controller or model method...
    url = URI.parse('https://qa4.networkforgood.org/PartnerDonationService/DonateService.asmx/MakeCCDonation')
    req = Net::HTTP::Post.new(url.path)
    req.set_form_data({ 'PartnerID' => DONATENOW_AUTH['PartnerID'],
                        'PartnerPW' => DONATENOW_AUTH['PartnerPW'],
                        'PartnerSource' => DONATENOW_AUTH['PartnerSource'],
                        'PartnerCampaign' => DONATENOW_AUTH['PartnerCampaign'],
                        'NpoEin' => @action.ein,
                        'Designation' => nil,
                        'Dedication' => nil,
                        'DonorNpoDisclosure' => @donation.disclosure,
                        'DonationAmount' => @donation.amount,
                        'PartnerTransactionIdentifier' => nil,
                        'DonorIpAddress' => request.remote_ip,
                        'DonorFirstName' => @donor.first_name,
                        'DonorLastName' => @donor.last_name,
                        'DonorEmail' => @donor.email,
                        'DonorAddress1' => @donor.address1,
                        'DonorAddress2' => @donor.address2,
                        'DonorCity' => @donor.city,
                        'DonorState' => @donor.state,
                        'DonorZip' => @donor.zip,
                        'DonorPhone' => "#{@donor.phone_1}#{@donor.phone_2}#{@donor.phone_3}",
                        'CardType' => @credit_card.card_type,
                        'NameOnCard' => @credit_card.name,
                        'CardNumber' => @credit_card.number,
                        'ExpMonth' => @credit_card.expiry_date.month,
                        'ExpYear' => @credit_card.expiry_date.year,
                        'CSC' => @credit_card.csc
                      })
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    res = http.request(req)

    puts "#{res.code} #{res.message}"

    unless res.is_a? Net::HTTPSuccess
      @donation.errors.add_to_base "There was a problem communicating with the donation processing service."
      puts res.body
      return render(:action => 'new')
    end

    dnres = Hash.from_xml(res.body)['DonationReturnData']

    require 'pp'
    pp dnres

    unless dnres['StatusCode'] == 'Success'
      if dnres['Message']
        @donation.errors.add_to_base dnres['Message']
      else
        errs = dnres['ErrorDetails']['ErrorInfo']
        errs = [errs] if errs.is_a?(Hash)
        
        errs.each do |err|
          @donation.errors.add_to_base err['ErrData']
          puts "adding to @donation: #{err['ErrData']}"
        end
      end
      
      return render(:action => 'new')
    end

    @chargeid = dnres['ChargeId']

    #puts "#{res.code} #{res.message}"
    #puts res.body
    #puts res.inspect
  end

protected 

  def load_action
    @action = Action.find(params[:social_action])
  end

end
