require 'rails_helper'

RSpec.describe ImportPayout  do
  let(:nepse_settlement) {create(:nepse_settlement)}
  let(:sales_share_transaction) {create(:sales_share_transaction)}
  let(:current_user) {create(:user)}
  let(:branch) {create(:branch)}
  before do
    UserSession.user = create(:user)
    UserSession.selected_branch_id = 1
    UserSession.selected_fy_code = 7374

    allow_any_instance_of(ImportPayout).to receive(:broker_commission_rate).and_return(0.8)
    allow_any_instance_of(ImportPayout).to receive(:nepse_commission_rate).and_return(0.2)
    # not testing the base price calculation here
    allow_any_instance_of(ShareTransaction).to receive(:calculate_base_price).and_return(100)
  end


  it 'should process sales for normal' do
    sales_share_transaction

    allow_any_instance_of(ImportPayout).to receive(:open_file).and_return(nil)

    import_payout_service = ImportPayout.new(nil, '2073-9-5', current_user, branch.id)
    import_payout_service.instance_variable_set(:@processed_data, [{"SETT_ID"=>"1211002016255", "TRADE_DATE"=>"28-Nov-16", "CMID"=>"99", "BUY_CM_ID"=>"25", "SCRIPTSHORTNAME"=>"NIBPO", "SCRIPTNUMBER"=>"2060", "CONTRACTNO"=>"201611284117936", "CLIENTCODE"=>"USER FOUR (SK4)", "QUANTITY"=>"185", "RATE"=>"626", "CONTRACTAMT"=>"115810", "NEPSE_COMMISSION"=>"127.391", "SEBON_COMMISSION"=>"17.372", "TDS"=>"76.435", "CGT"=>"0", "CLOSEOUT_AMOUNT"=>"0", "AMOUNTRECEIVABLE"=>"115588.802", "REMARKS"=>"Normal Trade", "PURCHASE_PRICE"=>"150716.32", "CG"=>"0", "ADJ_SELL_PRICE"=>"115130.673", nil=>nil}])

    import_payout_service.process
    expect(sales_share_transaction.reload.net_amount).to eq(115130.6726)
    expect(sales_share_transaction.reload.amount_receivable).to eq(115588.802)
  end

  it 'should process sales for partial closeout' do
    sales_share_transaction

    allow_any_instance_of(ImportPayout).to receive(:open_file).and_return(nil)

    import_payout_service = ImportPayout.new(nil, '2073-9-5',current_user, branch.id)
    import_payout_service.instance_variable_set(:@processed_data, [{"SETT_ID"=>"1211002016255", "TRADE_DATE"=>"28-Nov-16", "CMID"=>"99", "BUY_CM_ID"=>"25", "SCRIPTSHORTNAME"=>"NIBPO", "SCRIPTNUMBER"=>"2060", "CONTRACTNO"=>"201611284117936", "CLIENTCODE"=>"USER FOUR (SK4)", "QUANTITY"=>"185", "RATE"=>"626", "CONTRACTAMT"=>"115810", "NEPSE_COMMISSION"=>"127.391", "SEBON_COMMISSION"=>"17.372", "TDS"=>"76.435", "CGT"=>"0", "CLOSEOUT_AMOUNT"=>"15024", "AMOUNTRECEIVABLE"=>"100564.802", "REMARKS"=>"Normal Trade", "PURCHASE_PRICE"=>"150716.32", "CG"=>"0", "ADJ_SELL_PRICE"=>"115130.673", nil=>nil}])

    import_payout_service.process
    expect(sales_share_transaction.reload.closeout_amount).to eq(15024.0)

    expect(sales_share_transaction.reload.net_amount).to eq(115130.6726)
    # expect(sales_share_transaction.reload.net_amount).to eq(100106.6726)
    expect(sales_share_transaction.reload.amount_receivable).to eq(100564.802)

  end

  it 'should not generate the bill for full closeout and ledger entry' do
    sales_share_transaction

    allow_any_instance_of(ImportPayout).to receive(:open_file).and_return(nil)

    import_payout_service = ImportPayout.new(nil, '2073-9-5', current_user, branch.id)
    import_payout_service.instance_variable_set(:@processed_data, [{"SETT_ID"=>"1211002016255", "TRADE_DATE"=>"28-Nov-16", "CMID"=>"99", "BUY_CM_ID"=>"25", "SCRIPTSHORTNAME"=>"NIBPO", "SCRIPTNUMBER"=>"2060", "CONTRACTNO"=>"201611284117936", "CLIENTCODE"=>"USER FOUR (SK4)", "QUANTITY"=>"185", "RATE"=>"626", "CONTRACTAMT"=>"115810", "NEPSE_COMMISSION"=>"127.391", "SEBON_COMMISSION"=>"17.372", "TDS"=>"76.435", "CGT"=>"0", "CLOSEOUT_AMOUNT"=>"138972", "AMOUNTRECEIVABLE"=>"-23383.198", "REMARKS"=>"Normal Trade", "PURCHASE_PRICE"=>"150716.32", "CG"=>"0", "ADJ_SELL_PRICE"=>"115130.673", nil=>nil}])

    import_payout_service.process
    # expect(sales_share_transaction.reload.net_amount).to eq(-23841.3274)
    expect(sales_share_transaction.reload.net_amount).to eq(115130.6726)
    expect(sales_share_transaction.reload.amount_receivable).to eq(-23383.198)
  end
end