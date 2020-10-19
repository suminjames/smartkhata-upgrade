Failures:

  1) ChequeEntries::BounceActivity should bounce the cheque for voucher with single cheque entry and no bills
     Failure/Error: expect(activity.error_message).to be_nil

       expected: nil
            got: "Please select the current fiscal year"
     # ./spec/models/cheque_entries/bounce_activity_spec.rb:42:in `block (2 levels) in <main>'

  2) ChequeEntries::BounceActivity should bounce the cheque for voucher with single cheque entry and bill with full amount
     Failure/Error: expect(activity.error_message).to be_nil

       expected: nil
            got: "Please select the current fiscal year"
     # ./spec/models/cheque_entries/bounce_activity_spec.rb:65:in `block (2 levels) in <main>'

  3) ChequeEntries::BounceActivity should bounce the cheque for voucher with single cheque entry and bill with partial amount
     Failure/Error: expect(activity.error_message).to be_nil

       expected: nil
            got: "Please select the current fiscal year"
     # ./spec/models/cheque_entries/bounce_activity_spec.rb:88:in `block (2 levels) in <main>'

  4) ChequeEntries::BounceActivity should bounce the cheque for voucher with single cheque entry and bills with full amount
     Failure/Error: expect(activity.error_message).to be_nil

       expected: nil
            got: "Please select the current fiscal year"
     # ./spec/models/cheque_entries/bounce_activity_spec.rb:115:in `block (2 levels) in <main>'

  5) ChequeEntries::BounceActivity payment cheque should not bounce payment cheque
     Failure/Error: expect(activity.error_message).to eq("The cheque can not be bounced.")

       expected: "The cheque can not be bounced."
            got: "Please select the current fiscal year"

       (compared using ==)
     # ./spec/models/cheque_entries/bounce_activity_spec.rb:27:in `block (3 levels) in <main>'

  6) ChequeEntries::BounceActivity when multiple cheque receipt and bouncing single cheque bounces the cheque
     Failure/Error: expect(@activity.error_message).to be_nil

       expected: nil
            got: "Please select the current fiscal year"
     # ./spec/models/cheque_entries/bounce_activity_spec.rb:152:in `block (4 levels) in <main>'

  7) ChequeEntries::BounceActivity when multiple cheque receipt and bouncing single cheque reverses the voucher
     Failure/Error: expect(voucher.reload.reversed?).to be_truthy

       expected: truthy value
            got: false
     # ./spec/models/cheque_entries/bounce_activity_spec.rb:157:in `block (4 levels) in <main>'

  8) ChequeEntries::BounceActivity when multiple cheque receipt and bouncing single cheque created entry to ledger
     Failure/Error: expect(bank_ledger.particulars.count).to eq(2)

       expected: 2
            got: 1

       (compared using ==)
     # ./spec/models/cheque_entries/bounce_activity_spec.rb:164:in `block (4 levels) in <main>'

  9) ChequeEntries::BounceActivity when multiple cheque receipt and bouncing second cheque bounces the cheque
     Failure/Error: expect(@activity.error_message).to be_nil

       expected: nil
            got: "Please select the current fiscal year"
     # ./spec/models/cheque_entries/bounce_activity_spec.rb:179:in `block (4 levels) in <main>'

  10) ChequeEntries::BounceActivity when multiple cheque receipt and bouncing second cheque creates another voucher
      Failure/Error: expect(@cheque_entry_a.reload.vouchers.uniq.size).to eq(2)

        expected: 2
             got: 1

        (compared using ==)
      # ./spec/models/cheque_entries/bounce_activity_spec.rb:184:in `block (4 levels) in <main>'

  11) ChequeEntries::BounceActivity when multiple cheque receipt and bouncing second cheque created entry to ledger
      Failure/Error: expect(ledger.particulars.count).to eq(3)

        expected: 3
             got: 1

        (compared using ==)
      # ./spec/models/cheque_entries/bounce_activity_spec.rb:190:in `block (4 levels) in <main>'

  12) ChequeEntries::VoidActivity should void the cheque for voucher with single cheque entry and no bills
      Failure/Error: expect(activity.error_message).to be_nil

        expected: nil
             got: "Please select the current fiscal year"
      # ./spec/models/cheque_entries/void_activity_spec.rb:55:in `block (2 levels) in <main>'

  13) ChequeEntries::VoidActivity should void the cheque for voucher with multi cheque entry and no bills
      Failure/Error: expect(activity.error_message).to be_nil

        expected: nil
             got: "Please select the current fiscal year"
      # ./spec/models/cheque_entries/void_activity_spec.rb:83:in `block (2 levels) in <main>'

  14) ChequeEntries::VoidActivity should void the cheque for voucher with single cheque entry and bill with full amount
      Failure/Error: expect(activity.error_message).to be_nil

        expected: nil
             got: "Please select the current fiscal year"
      # ./spec/models/cheque_entries/void_activity_spec.rb:108:in `block (2 levels) in <main>'

  15) ChequeEntries::VoidActivity should void the cheque for voucher with single cheque entry and bill with partial amount
      Failure/Error: expect(activity.error_message).to be_nil

        expected: nil
             got: "Please select the current fiscal year"
      # ./spec/models/cheque_entries/void_activity_spec.rb:135:in `block (2 levels) in <main>'

  16) ChequeEntries::VoidActivity should void the cheque for voucher with multi cheque entry and bills
      Failure/Error: expect(activity.error_message).to be_nil

        expected: nil
             got: "Please select the current fiscal year"
      # ./spec/models/cheque_entries/void_activity_spec.rb:173:in `block (2 levels) in <main>'

  17) ChequeEntries::VoidActivity receipt cheque should not void receipt cheque
      Failure/Error: expect(activity.error_message).to eq("The cheque entry cant be made void.")

        expected: "The cheque entry cant be made void."
             got: "Please select the current fiscal year"

        (compared using ==)
      # ./spec/models/cheque_entries/void_activity_spec.rb:31:in `block (3 levels) in <main>'

  18) ChequeEntries::VoidActivity unassigned cheque should void cheque
      Failure/Error: expect(activity.error_message).to be_nil

        expected: nil
             got: "Please select the current fiscal year"
      # ./spec/models/cheque_entries/void_activity_spec.rb:41:in `block (3 levels) in <main>'

  19) ClientAccount.change_ledger_name updates the ledger name on client account update
      Failure/Error: expect(client_account.ledger.name).to eq("John")

        expected: "John"
             got: "Dedra Sorenson"

        (compared using ==)
      # ./spec/models/client_account_spec.rb:99:in `block (3 levels) in <main>'

  20) ClientAccount#find_similar_to_term when search term is present and matches name and nepse code is not present should return  attributes with nepse code
      Failure/Error: expect(subject.class.find_similar_to_term("De",1)).to eq([:text=> "Dedra Sorenson", :id => "#{subject.id}"])

        expected: [{:id=>"79", :text=>"Dedra Sorenson"}]
             got: []

        (compared using ==)

        Diff:
        @@ -1 +1 @@
        -[{:id=>"79", :text=>"Dedra Sorenson"}]
        +[]
      # ./spec/models/client_account_spec.rb:475:in `block (5 levels) in <main>'

  21) ClientAccount#find_similar_to_term when search term is present and matches name and nepse code is present should return  attributes with nepse code
      Failure/Error: expect(subject.class.find_similar_to_term("De",1)).to eq([:text=> "Dedra Sorenson (123)", :id => "#{subject.id}"])

        expected: [{:id=>"80", :text=>"Dedra Sorenson (123)"}]
             got: []

        (compared using ==)

        Diff:
        @@ -1 +1 @@
        -[{:id=>"80", :text=>"Dedra Sorenson (123)"}]
        +[]
      # ./spec/models/client_account_spec.rb:482:in `block (5 levels) in <main>'

  22) ClientAccount#find_similar_to_term when search term is present and matches nepse_code should return  attributes with nepse code
      Failure/Error: expect(subject.class.find_similar_to_term("np",1)).to eq([:text=> "Dedra Sorenson (nps)", :id => "#{subject.id}"])

        expected: [{:id=>"81", :text=>"Dedra Sorenson (nps)"}]
             got: []

        (compared using ==)

        Diff:
        @@ -1 +1 @@
        -[{:id=>"81", :text=>"Dedra Sorenson (nps)"}]
        +[]
      # ./spec/models/client_account_spec.rb:490:in `block (4 levels) in <main>'

  23) ClientAccount#find_similar_to_term when search term is not present should return  attributes with nepse code
      Failure/Error: expect(subject.class.find_similar_to_term(nil,1)).to eq([:text=> "Dedra Sorenson (nps)", :id => "#{subject.id}"])

        expected: [{:id=>"82", :text=>"Dedra Sorenson (nps)"}]
             got: []

        (compared using ==)

        Diff:
        @@ -1 +1 @@
        -[{:id=>"82", :text=>"Dedra Sorenson (nps)"}]
        +[]
      # ./spec/models/client_account_spec.rb:497:in `block (4 levels) in <main>'

  24) ClientAccount.move_particulars should move particulars when branch changed
      Failure/Error: expect(subject.move_particulars).to eq('random')

        expected: "random"
             got: #<MoveClientParticularJob:0x000055fb65aebf08 @arguments=[83, 1, 210], @job_id="59d90a7e-0c78-4897-b61...me="default", @priority=nil, @executions=0, @provider_job_id="2d74e6e2-597f-49f5-8e73-e94c70c7ce07">

        (compared using ==)

        Diff:
        @@ -1,7 +1,13 @@
        -"random"
        +#<MoveClientParticularJob:0x000055fb65aebf08
        + @arguments=[83, 1, 210],
        + @executions=0,
        + @job_id="59d90a7e-0c78-4897-b61d-1c66cfcef44b",
        + @priority=nil,
        + @provider_job_id="2d74e6e2-597f-49f5-8e73-e94c70c7ce07",
        + @queue_name="default">
      # ./spec/models/client_account_spec.rb:518:in `block (3 levels) in <main>'

  25) LedgerBalance#update_or_create_org_balance when org balance is not present should create org balance
      Failure/Error:
        def self.update_or_create_org_balance(ledger_id, fy_code, current_user_id)
          set_current_user = ->(l) { l.current_user_id = current_user_id }
          ledger_balance_org = LedgerBalance.unscoped.by_fy_code(fy_code).find_or_create_by!(ledger_id: ledger_id, branch_id: nil, &set_current_user)
          ledger_balance = LedgerBalance.unscoped.by_fy_code(fy_code).where(ledger_id: ledger_id).where.not(branch_id: nil).sum(:opening_balance)
          balance_type = ledger_balance >= 0 ? LedgerBalance.opening_balance_types[:dr] : LedgerBalance.opening_balance_types[:cr]
          ledger_balance_org.tap(&set_current_user)
          ledger_balance_org.update(opening_balance: ledger_balance, opening_balance_type: balance_type)
        end

      ArgumentError:
        wrong number of arguments (given 4, expected 3)
      # ./app/models/ledger_balance.rb:85:in `update_or_create_org_balance'
      # ./spec/models/ledger_balance_spec.rb:84:in `block (5 levels) in <main>'
      # ./spec/models/ledger_balance_spec.rb:84:in `block (4 levels) in <main>'

  26) LedgerBalance#update_or_create_org_balance when org balance is present should update org balance
      Failure/Error:
        def self.update_or_create_org_balance(ledger_id, fy_code, current_user_id)
          set_current_user = ->(l) { l.current_user_id = current_user_id }
          ledger_balance_org = LedgerBalance.unscoped.by_fy_code(fy_code).find_or_create_by!(ledger_id: ledger_id, branch_id: nil, &set_current_user)
          ledger_balance = LedgerBalance.unscoped.by_fy_code(fy_code).where(ledger_id: ledger_id).where.not(branch_id: nil).sum(:opening_balance)
          balance_type = ledger_balance >= 0 ? LedgerBalance.opening_balance_types[:dr] : LedgerBalance.opening_balance_types[:cr]
          ledger_balance_org.tap(&set_current_user)
          ledger_balance_org.update(opening_balance: ledger_balance, opening_balance_type: balance_type)
        end

      ArgumentError:
        wrong number of arguments (given 4, expected 3)
      # ./app/models/ledger_balance.rb:85:in `update_or_create_org_balance'
      # ./spec/models/ledger_balance_spec.rb:94:in `block (5 levels) in <main>'
      # ./spec/models/ledger_balance_spec.rb:94:in `block (4 levels) in <main>'

  27) LedgerDaily#sum_of_closing_balance_of_ledger_dailies_for_ledgers when last day ledger daily present should return sum of closing balance
      Failure/Error: subject{create(:ledger_daily, closing_balance: 1000, date: "2017-6-8" ,ledger: ledger, branch_id: 1, fy_code: 7374)}

      NoMethodError:
        undefined method `closing_balance=' for #<LedgerDaily:0x000055fb61ff7ac8>
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/attribute_assigner.rb:16:in `public_send'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/attribute_assigner.rb:16:in `block (2 levels) in object'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/attribute_assigner.rb:15:in `each'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/attribute_assigner.rb:15:in `block in object'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/attribute_assigner.rb:14:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/attribute_assigner.rb:14:in `object'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:13:in `object'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/ledger_daily_spec.rb:10:in `block (4 levels) in <main>'
      # ./spec/models/ledger_daily_spec.rb:13:in `block (4 levels) in <main>'

  28) LedgerDaily#sum_of_closing_balance_of_ledger_dailies_for_ledgers when last day daily ledger not present should return closing balance 0
      Failure/Error: expect(LedgerDaily.sum_of_closing_balance_of_ledger_dailies_for_ledgers(ledger.id,"2017-6-8", 7374, 1)).to eq(0)

      NoMethodError:
        undefined method `sum_of_closing_balance_of_ledger_dailies_for_ledgers' for #<Class:0x000055fb621bcdb8>
      # ./spec/models/ledger_daily_spec.rb:21:in `block (4 levels) in <main>'

  29) Ledger.update_closing_blnc when opening balance is not blank and opening balance type is cr should return closing balance
      Failure/Error: subject.opening_blnc = 800

      NoMethodError:
        undefined method `opening_blnc=' for #<Ledger:0x000055fb647223c8>
        Did you mean?  opening_balance
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/audited-4.9.0/lib/audited/auditor.rb:99:in `method_missing'
      # ./spec/models/ledger_spec.rb:77:in `block (5 levels) in <main>'

  30) Ledger.update_closing_blnc when opening balance is not blank and opening balance type is dr should return closing balance
      Failure/Error: subject.opening_blnc = 800

      NoMethodError:
        undefined method `opening_blnc=' for #<Ledger:0x000055fb648e9aa8>
        Did you mean?  opening_balance
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/audited-4.9.0/lib/audited/auditor.rb:99:in `method_missing'
      # ./spec/models/ledger_spec.rb:87:in `block (5 levels) in <main>'

  31) Ledger.update_closing_blnc when opening balance is blank should return opening balance equal to 0
      Failure/Error: expect(subject.opening_blnc).to eq(0)

      NoMethodError:
        undefined method `opening_blnc' for #<Ledger:0x000055fb64aafab8>
        Did you mean?  opening_balance
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/audited-4.9.0/lib/audited/auditor.rb:99:in `method_missing'
      # ./spec/models/ledger_spec.rb:97:in `block (4 levels) in <main>'

  32) Ledger.particulars_with_running_balance should return particulars with running balance
      Failure/Error: expect(particulars.first.running_total).to eq(particular1.amount)

        expected: 0.1e4
             got: 0.3e4

        (compared using ==)
      # ./spec/models/ledger_spec.rb:187:in `block (3 levels) in <main>'

  33) Ledger.positive_amount when opening balance is less than 1 should return error message
      Failure/Error: subject.opening_blnc = -400

      NoMethodError:
        undefined method `opening_blnc=' for #<Ledger:0x000055fb65f4f590>
        Did you mean?  opening_balance
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/audited-4.9.0/lib/audited/auditor.rb:99:in `method_missing'
      # ./spec/models/ledger_spec.rb:195:in `block (4 levels) in <main>'

  34) Ledger.closing_balance when session branch is branch office should return closing balance
      Failure/Error: expect(subject.closing_balance(7374, @branch.id)).to eq(3000)

        expected: 3000
             got: 0.0

        (compared using ==)
      # ./spec/models/ledger_spec.rb:223:in `block (4 levels) in <main>'

  35) Ledgers::ParticularEntry.calculate_balances when accounting date is before date and debit adds dr_amount and increments closing balance for ledger dailies for that day
      Failure/Error: expect(ledger_daily_subject.closing_balance).to eq(9000)

      NoMethodError:
        undefined method `closing_balance' for #<LedgerDaily:0x000055fb625a3cb0>
      # ./spec/models/ledgers/particular_entry_spec.rb:54:in `block (5 levels) in <main>'

  36) Ledgers::ParticularEntry.calculate_balances when accounting date is before date and debit carries the dr_amount, opening balance and closing balance to the future dates
      Failure/Error: expect(ledger_daily_future.reload.closing_balance).to eq(10000)

      NoMethodError:
        undefined method `closing_balance' for #<LedgerDaily:0x000055fb64fd83a0>
      # ./spec/models/ledgers/particular_entry_spec.rb:79:in `block (5 levels) in <main>'

  37) Ledgers::ParticularEntry.calculate_balances when accounting date is before date and debit returns closing balances
      Failure/Error: expect(@calculate_balances).to eq([9000, 10000])

        expected: [9000, 10000]
             got: true

        (compared using ==)
      # ./spec/models/ledgers/particular_entry_spec.rb:86:in `block (5 levels) in <main>'

  38) Ledgers::ParticularEntry.calculate_balances when accounting date is before date and credit adds cr_amount and decrements closing balance for ledger dailies for that day
      Failure/Error: expect(ledger_daily_subject.reload.closing_balance).to eq(1000)

      NoMethodError:
        undefined method `closing_balance' for #<LedgerDaily:0x000055fb61ed2ff8>
      # ./spec/models/ledgers/particular_entry_spec.rb:99:in `block (5 levels) in <main>'

  39) Ledgers::ParticularEntry.calculate_balances when accounting date is before date and credit carries the cr_amount, opening balance and closing balance to the future dates
      Failure/Error: expect(ledger_daily_future.reload.closing_balance).to eq(2000)

      NoMethodError:
        undefined method `closing_balance' for #<LedgerDaily:0x000055fb648503a8>
      # ./spec/models/ledgers/particular_entry_spec.rb:122:in `block (5 levels) in <main>'

  40) Ledgers::ParticularEntry.calculate_balances when accounting date is before date and credit returns closing balances
      Failure/Error: expect(@calculate_balances).to eq([1000, 2000])

        expected: [1000, 2000]
             got: true

        (compared using ==)
      # ./spec/models/ledgers/particular_entry_spec.rb:129:in `block (5 levels) in <main>'

  41) Ledgers::ParticularEntry.calculate_balances when accounting date is after date and debit creates new ledger dailies for that day
      Failure/Error: expect(ledger_daily.reload.closing_balance).to eq(10000)

      NoMethodError:
        undefined method `closing_balance' for #<LedgerDaily:0x000055fb65f9dc40>
      # ./spec/models/ledgers/particular_entry_spec.rb:144:in `block (5 levels) in <main>'

  42) Ledgers::ParticularEntry.calculate_balances when accounting date is after date and debit returns closing balances
      Failure/Error: expect(@calculate_balances).to eq([10000, 11000])

        expected: [10000, 11000]
             got: true

        (compared using ==)
      # ./spec/models/ledgers/particular_entry_spec.rb:165:in `block (5 levels) in <main>'

  43) Ledgers::ParticularEntry.calculate_balances when accounting date is after date and credit creates new ledger dailies for that day
      Failure/Error: expect(ledger_daily.reload.closing_balance).to eq(2000)

      NoMethodError:
        undefined method `closing_balance' for #<LedgerDaily:0x000055fb64d81318>
      # ./spec/models/ledgers/particular_entry_spec.rb:179:in `block (5 levels) in <main>'

  44) Ledgers::ParticularEntry.calculate_balances when accounting date is after date and credit returns closing balances
      Failure/Error: expect(@calculate_balances).to eq([2000, 3000])

        expected: [2000, 3000]
             got: true

        (compared using ==)
      # ./spec/models/ledgers/particular_entry_spec.rb:200:in `block (5 levels) in <main>'

  45) NepseSettlement.bills_for_payment_letter_list when require processing is true when net amount is greater than 0 should return bill
      Failure/Error:
        def bills_for_payment_letter_list(branch_id)
          # self.bills.to_a.select {|bill| bill.client_account.ledger.closing_balance < 0 && bill.requires_processing?}
          self.bills.by_branch_id(branch_id).to_a.select { |bill| bill.requires_processing? && bill.net_amount.positive? }
        end

      ArgumentError:
        wrong number of arguments (given 0, expected 1)
      # ./app/models/nepse_settlement.rb:22:in `bills_for_payment_letter_list'
      # ./spec/models/nepse_settlement_spec.rb:16:in `block (5 levels) in <main>'

  46) NepseSettlement.bills_for_payment_letter_list when require processing is true and net net_amount is less than 0 should return empty array
      Failure/Error:
        def bills_for_payment_letter_list(branch_id)
          # self.bills.to_a.select {|bill| bill.client_account.ledger.closing_balance < 0 && bill.requires_processing?}
          self.bills.by_branch_id(branch_id).to_a.select { |bill| bill.requires_processing? && bill.net_amount.positive? }
        end

      ArgumentError:
        wrong number of arguments (given 0, expected 1)
      # ./app/models/nepse_settlement.rb:22:in `bills_for_payment_letter_list'
      # ./spec/models/nepse_settlement_spec.rb:27:in `block (5 levels) in <main>'

  47) NepseSettlement.bills_for_payment_letter_list when require processing is not true should return empty array
      Failure/Error:
        def bills_for_payment_letter_list(branch_id)
          # self.bills.to_a.select {|bill| bill.client_account.ledger.closing_balance < 0 && bill.requires_processing?}
          self.bills.by_branch_id(branch_id).to_a.select { |bill| bill.requires_processing? && bill.net_amount.positive? }
        end

      ArgumentError:
        wrong number of arguments (given 0, expected 1)
      # ./app/models/nepse_settlement.rb:22:in `bills_for_payment_letter_list'
      # ./spec/models/nepse_settlement_spec.rb:38:in `block (4 levels) in <main>'

  48) NepseSettlement.bills_for_sales_payment_list when require processing is true and net amount is greater than 0 should return bill for sale payment
      Failure/Error:
        def bills_for_sales_payment_list(branch_id)
          # self.bills.to_a.select {|bill| bill.client_account.ledger.closing_balance < 0 && bill.requires_processing?}
          self.bills.by_branch_id(branch_id).to_a.select { |bill| bill.requires_processing? && bill.net_amount.positive? }
          # self.bills.to_a
        end

      ArgumentError:
        wrong number of arguments (given 0, expected 1)
      # ./app/models/nepse_settlement.rb:29:in `bills_for_sales_payment_list'
      # ./spec/models/nepse_settlement_spec.rb:51:in `block (5 levels) in <main>'

  49) NepseSettlement.bills_for_sales_payment_list when require processing is true and net amount is less than 0 should return empty array
      Failure/Error:
        def bills_for_sales_payment_list(branch_id)
          # self.bills.to_a.select {|bill| bill.client_account.ledger.closing_balance < 0 && bill.requires_processing?}
          self.bills.by_branch_id(branch_id).to_a.select { |bill| bill.requires_processing? && bill.net_amount.positive? }
          # self.bills.to_a
        end

      ArgumentError:
        wrong number of arguments (given 0, expected 1)
      # ./app/models/nepse_settlement.rb:29:in `bills_for_sales_payment_list'
      # ./spec/models/nepse_settlement_spec.rb:63:in `block (5 levels) in <main>'

  50) NepseSettlement.bills_for_sales_payment_list when require processing is not true should return empty array
      Failure/Error:
        def bills_for_sales_payment_list(branch_id)
          # self.bills.to_a.select {|bill| bill.client_account.ledger.closing_balance < 0 && bill.requires_processing?}
          self.bills.by_branch_id(branch_id).to_a.select { |bill| bill.requires_processing? && bill.net_amount.positive? }
          # self.bills.to_a
        end

      ArgumentError:
        wrong number of arguments (given 0, expected 1)
      # ./app/models/nepse_settlement.rb:29:in `bills_for_sales_payment_list'
      # ./spec/models/nepse_settlement_spec.rb:74:in `block (4 levels) in <main>'

  51) NepseSettlement#settlement_types should return array for settlement types
      Failure/Error: expect(subject.class.settlement_types).to eq(["NepsePurchaseSettlement","NepseSaleSettlement"])

        expected: ["NepsePurchaseSettlement", "NepseSaleSettlement"]
             got: ["NepsePurchaseSettlement", "NepseSaleSettlement", "NepseProvisionalSettlement"]

        (compared using ==)
      # ./spec/models/nepse_settlement_spec.rb:81:in `block (3 levels) in <main>'

  52) SmsMessage#sparrow_send_bill_sms successfully sending single sms sends sms using sparrow
      Failure/Error:
          def self.sparrow_send_bill_sms(transaction_message_id, current_user)
            transaction_message = TransactionMessage.find_by(id: transaction_message_id.to_i)
            _mobile_number = transaction_message.client_account.messageable_phone_number
            _branch_id = transaction_message.client_account.branch_id

            sms_message_obj = SmsMessage.new(phone: _mobile_number, sms_type: SmsMessage.sms_types[:transaction_message_sms], transaction_message_id: transaction_message.id, branch_id: _branch_id, current_user_id: current_user.id)
            _full_message = transaction_message.sms_message

            # 459 is size of max block sendable via sparrow sms
            valid_message_blocks = _full_message.scan(/.{1,459}/)

      ArgumentError:
        wrong number of arguments (given 1, expected 2)
      # ./app/models/sms_message.rb:189:in `sparrow_send_bill_sms'
      # ./spec/models/sms_message_spec.rb:28:in `block (5 levels) in <main>'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/vcr-6.0.0/lib/vcr/util/variable_args_block_caller.rb:9:in `call_block'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/vcr-6.0.0/lib/vcr.rb:194:in `use_cassette'
      # ./spec/models/sms_message_spec.rb:27:in `block (4 levels) in <main>'

  53) SmsMessage#sparrow_send_bill_sms successfully sending single sms stores sms credit
      Failure/Error:
          def self.sparrow_send_bill_sms(transaction_message_id, current_user)
            transaction_message = TransactionMessage.find_by(id: transaction_message_id.to_i)
            _mobile_number = transaction_message.client_account.messageable_phone_number
            _branch_id = transaction_message.client_account.branch_id

            sms_message_obj = SmsMessage.new(phone: _mobile_number, sms_type: SmsMessage.sms_types[:transaction_message_sms], transaction_message_id: transaction_message.id, branch_id: _branch_id, current_user_id: current_user.id)
            _full_message = transaction_message.sms_message

            # 459 is size of max block sendable via sparrow sms
            valid_message_blocks = _full_message.scan(/.{1,459}/)

      ArgumentError:
        wrong number of arguments (given 1, expected 2)
      # ./app/models/sms_message.rb:189:in `sparrow_send_bill_sms'
      # ./spec/models/sms_message_spec.rb:28:in `block (5 levels) in <main>'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/vcr-6.0.0/lib/vcr/util/variable_args_block_caller.rb:9:in `call_block'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/vcr-6.0.0/lib/vcr.rb:194:in `use_cassette'
      # ./spec/models/sms_message_spec.rb:27:in `block (4 levels) in <main>'

  54) SmsMessage#sparrow_send_bill_sms when sending multiple sms and message length is greater than 459 updates sms credit
      Failure/Error:
          def self.sparrow_send_bill_sms(transaction_message_id, current_user)
            transaction_message = TransactionMessage.find_by(id: transaction_message_id.to_i)
            _mobile_number = transaction_message.client_account.messageable_phone_number
            _branch_id = transaction_message.client_account.branch_id

            sms_message_obj = SmsMessage.new(phone: _mobile_number, sms_type: SmsMessage.sms_types[:transaction_message_sms], transaction_message_id: transaction_message.id, branch_id: _branch_id, current_user_id: current_user.id)
            _full_message = transaction_message.sms_message

            # 459 is size of max block sendable via sparrow sms
            valid_message_blocks = _full_message.scan(/.{1,459}/)

      ArgumentError:
        wrong number of arguments (given 1, expected 2)
      # ./app/models/sms_message.rb:189:in `sparrow_send_bill_sms'
      # ./spec/models/sms_message_spec.rb:49:in `block (5 levels) in <main>'

  55) Vouchers::Base.set_bill_client should return error when other bill ids are sent
      Failure/Error: expect { @assert_smartkhata_error.call(voucher_base, client_account_id, bill_ids, false) }.to raise_error(SmartKhataError)
        expected SmartKhataError but nothing was raised
      # ./spec/models/vouchers/base_spec.rb:178:in `block (3 levels) in <main>'

  56) Vouchers::Create basic vouchers should create a journal voucher
      Failure/Error: expect(voucher_creation.process).to be_truthy

        expected: truthy value
             got: false
      # ./spec/models/vouchers/create_spec.rb:169:in `block (3 levels) in <main>'

  57) Vouchers::Create basic vouchers should create a payment voucher
      Failure/Error: expect(voucher_creation.process).to be_truthy

        expected: truthy value
             got: false
      # ./spec/models/vouchers/create_spec.rb:186:in `block (3 levels) in <main>'

  58) Vouchers::Create basic vouchers should create a receipt voucher
      Failure/Error: expect(voucher_creation.process).to be_truthy

        expected: truthy value
             got: false
      # ./spec/models/vouchers/create_spec.rb:203:in `block (3 levels) in <main>'

  59) Vouchers::Create duplicate cheque entry should not create receipt voucher with duplicate cheque entry
      Failure/Error: expect(voucher_creation_1.process).to be_truthy

        expected: truthy value
             got: false
      # ./spec/models/vouchers/create_spec.rb:225:in `block (3 levels) in <main>'

  60) Vouchers::Create duplicate cheque entry should create receipt voucher for bounced cheque entry
      Failure/Error: expect(voucher_creation_1.process).to be_truthy

        expected: truthy value
             got: false
      # ./spec/models/vouchers/create_spec.rb:259:in `block (3 levels) in <main>'

  61) Vouchers::Create complex receipt vouchers should settle purchase bill with full amount
      Failure/Error: expect(voucher_creation.error_message).to be_nil

        expected: nil
             got: "Branch is not correct"
      # ./spec/models/vouchers/create_spec.rb:302:in `block (3 levels) in <main>'

  62) Vouchers::Create complex receipt vouchers should partially settle purchase bill with partial amount
      Failure/Error: expect(voucher_creation.error_message).to be_nil

        expected: nil
             got: "Branch is not correct"
      # ./spec/models/vouchers/create_spec.rb:338:in `block (3 levels) in <main>'

  63) Vouchers::Create complex receipt vouchers should settle purchase bill with ledger having advance amount
      Failure/Error: expect(voucher_creation.error_message).to be_nil

        expected: nil
             got: "Branch is not correct"
      # ./spec/models/vouchers/create_spec.rb:376:in `block (3 levels) in <main>'

  64) Vouchers::Create complex payment should settle sales bill with full amount
      Failure/Error: expect(voucher_creation.error_message).to be_nil

        expected: nil
             got: "Branch is not correct"
      # ./spec/models/vouchers/create_spec.rb:410:in `block (3 levels) in <main>'

  65) Vouchers::Create complex payment should partially settle sales bill with partial amount
      Failure/Error: expect(voucher_creation.error_message).to be_nil

        expected: nil
             got: "Branch is not correct"
      # ./spec/models/vouchers/create_spec.rb:445:in `block (3 levels) in <main>'

  66) Vouchers::Create complex payment should settle sales bill with ledger having advance amount
      Failure/Error: expect(voucher_creation.error_message).to be_nil

        expected: nil
             got: "Branch is not correct"
      # ./spec/models/vouchers/create_spec.rb:479:in `block (3 levels) in <main>'

  67) Vouchers::Create complex payment and receipt should settle both type of bills
      Failure/Error: expect(voucher_creation.error_message).to be_nil

        expected: nil
             got: "Branch is not correct"
      # ./spec/models/vouchers/create_spec.rb:516:in `block (3 levels) in <main>'

  68) Vouchers::Setup clear ledgers advanced vouchers should build a receipt voucher when ledger balance is in dr
      Failure/Error: expect(voucher.voucher_code).to eq("RCV")

        expected: "RCV"
             got: "PMT"

        (compared using ==)
      # ./spec/models/vouchers/setup_spec.rb:80:in `block (3 levels) in <main>'

Finished in 28.92 seconds (files took 2.24 seconds to load)
577 examples, 68 failures, 8 pending

Failed examples:

rspec ./spec/models/cheque_entries/bounce_activity_spec.rb:32 # ChequeEntries::BounceActivity should bounce the cheque for voucher with single cheque entry and no bills
rspec ./spec/models/cheque_entries/bounce_activity_spec.rb:49 # ChequeEntries::BounceActivity should bounce the cheque for voucher with single cheque entry and bill with full amount
rspec ./spec/models/cheque_entries/bounce_activity_spec.rb:72 # ChequeEntries::BounceActivity should bounce the cheque for voucher with single cheque entry and bill with partial amount
rspec ./spec/models/cheque_entries/bounce_activity_spec.rb:96 # ChequeEntries::BounceActivity should bounce the cheque for voucher with single cheque entry and bills with full amount
rspec ./spec/models/cheque_entries/bounce_activity_spec.rb:23 # ChequeEntries::BounceActivity payment cheque should not bounce payment cheque
rspec ./spec/models/cheque_entries/bounce_activity_spec.rb:151 # ChequeEntries::BounceActivity when multiple cheque receipt and bouncing single cheque bounces the cheque
rspec ./spec/models/cheque_entries/bounce_activity_spec.rb:156 # ChequeEntries::BounceActivity when multiple cheque receipt and bouncing single cheque reverses the voucher
rspec ./spec/models/cheque_entries/bounce_activity_spec.rb:161 # ChequeEntries::BounceActivity when multiple cheque receipt and bouncing single cheque created entry to ledger
rspec ./spec/models/cheque_entries/bounce_activity_spec.rb:178 # ChequeEntries::BounceActivity when multiple cheque receipt and bouncing second cheque bounces the cheque
rspec ./spec/models/cheque_entries/bounce_activity_spec.rb:183 # ChequeEntries::BounceActivity when multiple cheque receipt and bouncing second cheque creates another voucher
rspec ./spec/models/cheque_entries/bounce_activity_spec.rb:187 # ChequeEntries::BounceActivity when multiple cheque receipt and bouncing second cheque created entry to ledger
rspec ./spec/models/cheque_entries/void_activity_spec.rb:46 # ChequeEntries::VoidActivity should void the cheque for voucher with single cheque entry and no bills
rspec ./spec/models/cheque_entries/void_activity_spec.rb:62 # ChequeEntries::VoidActivity should void the cheque for voucher with multi cheque entry and no bills
rspec ./spec/models/cheque_entries/void_activity_spec.rb:89 # ChequeEntries::VoidActivity should void the cheque for voucher with single cheque entry and bill with full amount
rspec ./spec/models/cheque_entries/void_activity_spec.rb:116 # ChequeEntries::VoidActivity should void the cheque for voucher with single cheque entry and bill with partial amount
rspec ./spec/models/cheque_entries/void_activity_spec.rb:143 # ChequeEntries::VoidActivity should void the cheque for voucher with multi cheque entry and bills
rspec ./spec/models/cheque_entries/void_activity_spec.rb:27 # ChequeEntries::VoidActivity receipt cheque should not void receipt cheque
rspec ./spec/models/cheque_entries/void_activity_spec.rb:36 # ChequeEntries::VoidActivity unassigned cheque should void cheque
rspec ./spec/models/client_account_spec.rb:96 # ClientAccount.change_ledger_name updates the ledger name on client account update
rspec ./spec/models/client_account_spec.rb:473 # ClientAccount#find_similar_to_term when search term is present and matches name and nepse code is not present should return  attributes with nepse code
rspec ./spec/models/client_account_spec.rb:480 # ClientAccount#find_similar_to_term when search term is present and matches name and nepse code is present should return  attributes with nepse code
rspec ./spec/models/client_account_spec.rb:488 # ClientAccount#find_similar_to_term when search term is present and matches nepse_code should return  attributes with nepse code
rspec ./spec/models/client_account_spec.rb:495 # ClientAccount#find_similar_to_term when search term is not present should return  attributes with nepse code
rspec ./spec/models/client_account_spec.rb:513 # ClientAccount.move_particulars should move particulars when branch changed
rspec ./spec/models/ledger_balance_spec.rb:82 # LedgerBalance#update_or_create_org_balance when org balance is not present should create org balance
rspec ./spec/models/ledger_balance_spec.rb:89 # LedgerBalance#update_or_create_org_balance when org balance is present should update org balance
rspec ./spec/models/ledger_daily_spec.rb:12 # LedgerDaily#sum_of_closing_balance_of_ledger_dailies_for_ledgers when last day ledger daily present should return sum of closing balance
rspec ./spec/models/ledger_daily_spec.rb:20 # LedgerDaily#sum_of_closing_balance_of_ledger_dailies_for_ledgers when last day daily ledger not present should return closing balance 0
rspec ./spec/models/ledger_spec.rb:76 # Ledger.update_closing_blnc when opening balance is not blank and opening balance type is cr should return closing balance
rspec ./spec/models/ledger_spec.rb:86 # Ledger.update_closing_blnc when opening balance is not blank and opening balance type is dr should return closing balance
rspec ./spec/models/ledger_spec.rb:96 # Ledger.update_closing_blnc when opening balance is blank should return opening balance equal to 0
rspec ./spec/models/ledger_spec.rb:179 # Ledger.particulars_with_running_balance should return particulars with running balance
rspec ./spec/models/ledger_spec.rb:194 # Ledger.positive_amount when opening balance is less than 1 should return error message
rspec ./spec/models/ledger_spec.rb:220 # Ledger.closing_balance when session branch is branch office should return closing balance
rspec ./spec/models/ledgers/particular_entry_spec.rb:50 # Ledgers::ParticularEntry.calculate_balances when accounting date is before date and debit adds dr_amount and increments closing balance for ledger dailies for that day
rspec ./spec/models/ledgers/particular_entry_spec.rb:76 # Ledgers::ParticularEntry.calculate_balances when accounting date is before date and debit carries the dr_amount, opening balance and closing balance to the future dates
rspec ./spec/models/ledgers/particular_entry_spec.rb:85 # Ledgers::ParticularEntry.calculate_balances when accounting date is before date and debit returns closing balances
rspec ./spec/models/ledgers/particular_entry_spec.rb:95 # Ledgers::ParticularEntry.calculate_balances when accounting date is before date and credit adds cr_amount and decrements closing balance for ledger dailies for that day
rspec ./spec/models/ledgers/particular_entry_spec.rb:120 # Ledgers::ParticularEntry.calculate_balances when accounting date is before date and credit carries the cr_amount, opening balance and closing balance to the future dates
rspec ./spec/models/ledgers/particular_entry_spec.rb:128 # Ledgers::ParticularEntry.calculate_balances when accounting date is before date and credit returns closing balances
rspec ./spec/models/ledgers/particular_entry_spec.rb:139 # Ledgers::ParticularEntry.calculate_balances when accounting date is after date and debit creates new ledger dailies for that day
rspec ./spec/models/ledgers/particular_entry_spec.rb:164 # Ledgers::ParticularEntry.calculate_balances when accounting date is after date and debit returns closing balances
rspec ./spec/models/ledgers/particular_entry_spec.rb:173 # Ledgers::ParticularEntry.calculate_balances when accounting date is after date and credit creates new ledger dailies for that day
rspec ./spec/models/ledgers/particular_entry_spec.rb:199 # Ledgers::ParticularEntry.calculate_balances when accounting date is after date and credit returns closing balances
rspec ./spec/models/nepse_settlement_spec.rb:12 # NepseSettlement.bills_for_payment_letter_list when require processing is true when net amount is greater than 0 should return bill
rspec ./spec/models/nepse_settlement_spec.rb:23 # NepseSettlement.bills_for_payment_letter_list when require processing is true and net net_amount is less than 0 should return empty array
rspec ./spec/models/nepse_settlement_spec.rb:34 # NepseSettlement.bills_for_payment_letter_list when require processing is not true should return empty array
rspec ./spec/models/nepse_settlement_spec.rb:47 # NepseSettlement.bills_for_sales_payment_list when require processing is true and net amount is greater than 0 should return bill for sale payment
rspec ./spec/models/nepse_settlement_spec.rb:59 # NepseSettlement.bills_for_sales_payment_list when require processing is true and net amount is less than 0 should return empty array
rspec ./spec/models/nepse_settlement_spec.rb:70 # NepseSettlement.bills_for_sales_payment_list when require processing is not true should return empty array
rspec ./spec/models/nepse_settlement_spec.rb:80 # NepseSettlement#settlement_types should return array for settlement types
rspec ./spec/models/sms_message_spec.rb:32 # SmsMessage#sparrow_send_bill_sms successfully sending single sms sends sms using sparrow
rspec ./spec/models/sms_message_spec.rb:37 # SmsMessage#sparrow_send_bill_sms successfully sending single sms stores sms credit
rspec ./spec/models/sms_message_spec.rb:47 # SmsMessage#sparrow_send_bill_sms when sending multiple sms and message length is greater than 459 updates sms credit
rspec ./spec/models/vouchers/base_spec.rb:171 # Vouchers::Base.set_bill_client should return error when other bill ids are sent
rspec ./spec/models/vouchers/create_spec.rb:158 # Vouchers::Create basic vouchers should create a journal voucher
rspec ./spec/models/vouchers/create_spec.rb:173 # Vouchers::Create basic vouchers should create a payment voucher
rspec ./spec/models/vouchers/create_spec.rb:190 # Vouchers::Create basic vouchers should create a receipt voucher
rspec ./spec/models/vouchers/create_spec.rb:209 # Vouchers::Create duplicate cheque entry should not create receipt voucher with duplicate cheque entry
rspec ./spec/models/vouchers/create_spec.rb:243 # Vouchers::Create duplicate cheque entry should create receipt voucher for bounced cheque entry
rspec ./spec/models/vouchers/create_spec.rb:282 # Vouchers::Create complex receipt vouchers should settle purchase bill with full amount
rspec ./spec/models/vouchers/create_spec.rb:314 # Vouchers::Create complex receipt vouchers should partially settle purchase bill with partial amount
rspec ./spec/models/vouchers/create_spec.rb:348 # Vouchers::Create complex receipt vouchers should settle purchase bill with ledger having advance amount
rspec ./spec/models/vouchers/create_spec.rb:388 # Vouchers::Create complex payment should settle sales bill with full amount
rspec ./spec/models/vouchers/create_spec.rb:420 # Vouchers::Create complex payment should partially settle sales bill with partial amount
rspec ./spec/models/vouchers/create_spec.rb:453 # Vouchers::Create complex payment should settle sales bill with ledger having advance amount
rspec ./spec/models/vouchers/create_spec.rb:489 # Vouchers::Create complex payment and receipt should settle both type of bills
rspec ./spec/models/vouchers/setup_spec.rb:70 # Vouchers::Setup clear ledgers advanced vouchers should build a receipt voucher when ledger balance is in dr

