namespace :mandala do
  desc "sync brokers"
  task :sync_brokers,[:tenant] => 'mandala:validate_tenant' do |task,args|
    Mandala::BrokerParameter.all.each do |broker|
      BrokerProfile.find_or_create_by!(broker_number: broker.broker_no) do |b|
        b.broker_name = broker.org_name
        b.address = broker.org_address
        b.broker_number = broker.broker_no
        b.phone_number = broker.off_tel_no
      end
    end
  end
end
