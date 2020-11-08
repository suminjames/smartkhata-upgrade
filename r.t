Failures:

  1) BankAccount.save_custom should create ledger for bank account
     Failure/Error: ledger_balance_org = LedgerBalance.unscoped.by_fy_code(fy_code).find_or_create_by!(ledger_id: ledger_id, branch_id: nil, &set_current_user)

     ActiveRecord::RecordInvalid:
       Validation failed: Branch must exist
     # ./app/models/ledger_balance.rb:87:in `update_or_create_org_balance'
     # ./app/models/bank_account.rb:93:in `block in save_custom'
     # ./app/models/bank_account.rb:91:in `save_custom'
     # ./spec/models/bank_account_spec.rb:75:in `block (3 levels) in <top (required)>'

  2) Bill validations is expected to belong to client_account required: true
     Failure/Error: it { should belong_to(:client_account) }
       Expected Bill to have a belongs_to association called client_account (and for the record to fail validation if :client_account is unset; i.e., either the association should have been defined with `required: true`, or there should be a presence validation on :client_account)
     # ./spec/models/bill_spec.rb:14:in `block (3 levels) in <main>'

  3) Bill.get_net_share_amount should return total share amount
     Failure/Error: expect(subject.get_net_share_amount).to eq(115810.0)

       expected: 115810.0
            got: 0

       (compared using ==)
     # ./spec/models/bill_spec.rb:29:in `block (3 levels) in <main>'

  4) Bill.get_net_sebo_commission should return total sebo commission
     Failure/Error: expect(subject.get_net_sebo_commission).to eq(17.315)

       expected: 17.315
            got: 0

       (compared using ==)
     # ./spec/models/bill_spec.rb:37:in `block (3 levels) in <main>'

  5) Bill.get_net_commission should return total commission
     Failure/Error: expect(subject.get_net_commission.to_f).to eq(636.96)

       expected: 636.96
            got: 0.0

       (compared using ==)
     # ./spec/models/bill_spec.rb:43:in `block (3 levels) in <main>'

  6) Bill#new_bill_number when previous bills are present for fycode should get new bill number
     Failure/Error: expect(subject.class.new_bill_number(subject.fy_code)).to eq(subject.bill_number + 1 )

       expected: 15
            got: 1

       (compared using ==)
     # ./spec/models/bill_spec.rb:93:in `block (4 levels) in <main>'

  7) Bill.make_provisional validations when share transaction bill is present should be have errors
     Failure/Error: create(:sales_share_transaction, date: subject.bs_to_ad(subject.date_bs), bill: create(:bill), client_account_id: subject.client_account_id)

     ActiveRecord::RecordInvalid:
       Validation failed: Branch must exist, Voucher must exist, Client account must exist
     # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
     # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
     # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
     # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
     # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
     # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
     # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
     # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
     # ./spec/models/bill_spec.rb:152:in `block (5 levels) in <main>'

  8) Bill.make_provisional when valid should assign correct date
     Failure/Error: create(:sales_share_transaction, date: subject.bs_to_ad(subject.date_bs), client_account_id: subject.client_account_id)

     ActiveRecord::RecordInvalid:
       Validation failed: Branch must exist, Voucher must exist, Client account must exist
     # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
     # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
     # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
     # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
     # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
     # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
     # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
     # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
     # ./spec/models/bill_spec.rb:163:in `block (4 levels) in <main>'

  9) Bill.make_provisional when valid should assign bill type
     Failure/Error: create(:sales_share_transaction, date: subject.bs_to_ad(subject.date_bs), client_account_id: subject.client_account_id)

     ActiveRecord::RecordInvalid:
       Validation failed: Branch must exist, Voucher must exist, Client account must exist
     # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
     # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
     # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
     # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
     # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
     # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
     # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
     # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
     # ./spec/models/bill_spec.rb:163:in `block (4 levels) in <main>'

  10) Bill.make_provisional when valid should assign status
      Failure/Error: create(:sales_share_transaction, date: subject.bs_to_ad(subject.date_bs), client_account_id: subject.client_account_id)

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist, Voucher must exist, Client account must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/bill_spec.rb:163:in `block (4 levels) in <main>'

  11) Bill.make_provisional when valid should assign bill number
      Failure/Error: create(:sales_share_transaction, date: subject.bs_to_ad(subject.date_bs), client_account_id: subject.client_account_id)

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist, Voucher must exist, Client account must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/bill_spec.rb:163:in `block (4 levels) in <main>'

  12) ChequeEntries::Activity.process when invalid fy_code adds error
      Failure/Error: let(:cheque_entry) { create(:cheque_entry, branch_id: 1) }

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist, Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/activity_spec.rb:9:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/activity_spec.rb:10:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/activity_spec.rb:20:in `block (4 levels) in <main>'

  13) ChequeEntries::Activity.process when activity cant be done returns nil
      Failure/Error: let(:cheque_entry) { create(:cheque_entry, branch_id: 1) }

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist, Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/activity_spec.rb:9:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/activity_spec.rb:10:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/activity_spec.rb:28:in `block (4 levels) in <main>'

  14) ChequeEntries::Activity.process when invalid branch adds error
      Failure/Error: let(:cheque_entry) { create(:cheque_entry, branch_id: 1) }

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist, Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/activity_spec.rb:9:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/activity_spec.rb:10:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/activity_spec.rb:36:in `block (4 levels) in <main>'

  15) ChequeEntries::Activity.process when perform action raises error
      Failure/Error: let(:cheque_entry) { create(:cheque_entry, branch_id: 1) }

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist, Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/activity_spec.rb:9:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/activity_spec.rb:10:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/activity_spec.rb:46:in `block (4 levels) in <main>'

  16) ChequeEntries::Activity.perform_action raises error
      Failure/Error: expect{subject.perform_action}.to raise_error(NotImplementedError)

        expected NotImplementedError, got #<ActiveRecord::RecordInvalid: Validation failed: Branch must exist, Additional bank must exist> with backtrace:
          # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
          # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
          # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
          # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
          # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
          # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
          # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
          # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
          # ./spec/models/cheque_entries/activity_spec.rb:9:in `block (2 levels) in <main>'
          # ./spec/models/cheque_entries/activity_spec.rb:10:in `block (2 levels) in <main>'
          # ./spec/models/cheque_entries/activity_spec.rb:56:in `block (4 levels) in <main>'
          # ./spec/models/cheque_entries/activity_spec.rb:56:in `block (3 levels) in <main>'
      # ./spec/models/cheque_entries/activity_spec.rb:56:in `block (3 levels) in <main>'

  17) ChequeEntries::Activity.can_activity_be_done? returns false
      Failure/Error: let(:cheque_entry) { create(:cheque_entry, branch_id: 1) }

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist, Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/activity_spec.rb:9:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/activity_spec.rb:10:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/activity_spec.rb:62:in `block (3 levels) in <main>'

  18) ChequeEntries::Activity.valid_branch? when branch matched to user selected branch returns true
      Failure/Error: let(:cheque_entry) { create(:cheque_entry, branch_id: 1) }

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist, Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/activity_spec.rb:9:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/activity_spec.rb:10:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/activity_spec.rb:69:in `block (4 levels) in <main>'

  19) ChequeEntries::Activity.valid_branch? when branch unmatched to user selected branch returns false
      Failure/Error: let(:cheque_entry) { create(:cheque_entry, branch_id: 1) }

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist, Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/activity_spec.rb:9:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/activity_spec.rb:10:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/activity_spec.rb:75:in `block (4 levels) in <main>'

  20) ChequeEntries::Activity.valid_for_the_fiscal_year? when fy_code matched to user selected fy_code returns true
      Failure/Error: let(:cheque_entry) { create(:cheque_entry, branch_id: 1) }

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist, Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/activity_spec.rb:9:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/activity_spec.rb:10:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/activity_spec.rb:84:in `block (4 levels) in <main>'

  21) ChequeEntries::Activity.valid_for_the_fiscal_year? when fy_code not matched to user selected fy_code returns false
      Failure/Error: let(:cheque_entry) { create(:cheque_entry, branch_id: 1) }

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist, Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/activity_spec.rb:9:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/activity_spec.rb:10:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/activity_spec.rb:90:in `block (4 levels) in <main>'

  22) ChequeEntries::Activity.set_error returns error message
      Failure/Error: let(:cheque_entry) { create(:cheque_entry, branch_id: 1) }

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist, Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/activity_spec.rb:9:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/activity_spec.rb:10:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/activity_spec.rb:99:in `block (3 levels) in <main>'

  23) ChequeEntries::Activity.get_bank_name_and_date when additional bank id present and cheque date not present returns array
      Failure/Error: let(:cheque_entry) { create(:cheque_entry, branch_id: 1) }

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist, Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/activity_spec.rb:9:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/activity_spec.rb:108:in `block (5 levels) in <main>'

  24) ChequeEntries::Activity.get_bank_name_and_date when additional bank id present and cheque date present returns array
      Failure/Error: let(:cheque_entry) { create(:cheque_entry, branch_id: 1) }

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist, Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/activity_spec.rb:9:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/activity_spec.rb:119:in `block (5 levels) in <main>'

  25) ChequeEntries::Activity.get_bank_name_and_date when additional bank id not present and cheque date not present and beneficiary name present returns array
      Failure/Error: let(:cheque_entry) { create(:cheque_entry, branch_id: 1) }

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist, Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/activity_spec.rb:9:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/activity_spec.rb:132:in `block (6 levels) in <main>'

  26) ChequeEntries::Activity.get_bank_name_and_date when additional bank id not present and cheque date not present and beneficiary name not present returns array
      Failure/Error: let(:cheque_entry) { create(:cheque_entry, branch_id: 1) }

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist, Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/activity_spec.rb:9:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/activity_spec.rb:146:in `block (6 levels) in <main>'

  27) ChequeEntries::Activity.get_bank_name_and_date when additional bank id not present and cheque date present and beneficiary name present returns array
      Failure/Error: let(:cheque_entry) { create(:cheque_entry, branch_id: 1) }

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist, Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/activity_spec.rb:9:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/activity_spec.rb:164:in `block (6 levels) in <main>'

  28) ChequeEntries::Activity.get_bank_name_and_date when additional bank id not present and cheque date present and beneficiary name not present returns array
      Failure/Error: let(:cheque_entry) { create(:cheque_entry, branch_id: 1) }

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist, Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/activity_spec.rb:9:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/activity_spec.rb:175:in `block (6 levels) in <main>'

  29) ChequeEntries::BounceActivity should bounce the cheque for voucher with single cheque entry and no bills
      Failure/Error: cheque_entry = create(:receipt_cheque_entry, status: :approved, branch_id: 1)

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist, Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/bounce_activity_spec.rb:34:in `block (2 levels) in <main>'

  30) ChequeEntries::BounceActivity should bounce the cheque for voucher with single cheque entry and bill with full amount
      Failure/Error: cheque_entry = create(:receipt_cheque_entry, status: :approved, amount: 5000, cheque_date: cheque_date_ad, branch_id: 1)

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist, Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/bounce_activity_spec.rb:50:in `block (2 levels) in <main>'

  31) ChequeEntries::BounceActivity should bounce the cheque for voucher with single cheque entry and bill with partial amount
      Failure/Error: cheque_entry = create(:receipt_cheque_entry, status: :approved, amount: 4000, cheque_date: cheque_date_ad, branch_id: 1)

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist, Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/bounce_activity_spec.rb:73:in `block (2 levels) in <main>'

  32) ChequeEntries::BounceActivity should bounce the cheque for voucher with single cheque entry and bills with full amount
      Failure/Error: cheque_entry = create(:receipt_cheque_entry, status: :approved, amount: 5000, cheque_date: cheque_date_ad, branch_id: 1)

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist, Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/bounce_activity_spec.rb:97:in `block (2 levels) in <main>'

  33) ChequeEntries::BounceActivity invalid fiscal year should return error if fycode is different than current
      Failure/Error: subject { create(:receipt_cheque_entry) }

      ActiveRecord::RecordInvalid:
        Validation failed: Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/bounce_activity_spec.rb:11:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/bounce_activity_spec.rb:15:in `block (3 levels) in <main>'

  34) ChequeEntries::BounceActivity payment cheque should not bounce payment cheque
      Failure/Error: subject { create(:receipt_cheque_entry) }

      ActiveRecord::RecordInvalid:
        Validation failed: Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/bounce_activity_spec.rb:11:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/bounce_activity_spec.rb:24:in `block (3 levels) in <main>'

  35) ChequeEntries::BounceActivity when multiple cheque receipt and bouncing single cheque bounces the cheque
      Failure/Error: subject { create(:receipt_cheque_entry) }

      ActiveRecord::RecordInvalid:
        Validation failed: Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/bounce_activity_spec.rb:11:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/bounce_activity_spec.rb:133:in `block (3 levels) in <main>'

  36) ChequeEntries::BounceActivity when multiple cheque receipt and bouncing single cheque reverses the voucher
      Failure/Error: subject { create(:receipt_cheque_entry) }

      ActiveRecord::RecordInvalid:
        Validation failed: Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/bounce_activity_spec.rb:11:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/bounce_activity_spec.rb:133:in `block (3 levels) in <main>'

  37) ChequeEntries::BounceActivity when multiple cheque receipt and bouncing single cheque created entry to ledger
      Failure/Error: subject { create(:receipt_cheque_entry) }

      ActiveRecord::RecordInvalid:
        Validation failed: Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/bounce_activity_spec.rb:11:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/bounce_activity_spec.rb:133:in `block (3 levels) in <main>'

  38) ChequeEntries::BounceActivity when multiple cheque receipt and bouncing second cheque bounces the cheque
      Failure/Error: subject { create(:receipt_cheque_entry) }

      ActiveRecord::RecordInvalid:
        Validation failed: Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/bounce_activity_spec.rb:11:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/bounce_activity_spec.rb:133:in `block (3 levels) in <main>'

  39) ChequeEntries::BounceActivity when multiple cheque receipt and bouncing second cheque creates another voucher
      Failure/Error: subject { create(:receipt_cheque_entry) }

      ActiveRecord::RecordInvalid:
        Validation failed: Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/bounce_activity_spec.rb:11:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/bounce_activity_spec.rb:133:in `block (3 levels) in <main>'

  40) ChequeEntries::BounceActivity when multiple cheque receipt and bouncing second cheque created entry to ledger
      Failure/Error: subject { create(:receipt_cheque_entry) }

      ActiveRecord::RecordInvalid:
        Validation failed: Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/bounce_activity_spec.rb:11:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/bounce_activity_spec.rb:133:in `block (3 levels) in <main>'

  41) ChequeEntries::VoidActivity should void the cheque for voucher with single cheque entry and no bills
      Failure/Error: subject { create(:cheque_entry) }

      ActiveRecord::RecordInvalid:
        Validation failed: Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/void_activity_spec.rb:13:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/void_activity_spec.rb:47:in `block (2 levels) in <main>'

  42) ChequeEntries::VoidActivity should void the cheque for voucher with multi cheque entry and no bills
      Failure/Error: cheque_entry = create(:cheque_entry, status: :approved, branch_id: 1, current_user_id: user.id)

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist, Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/void_activity_spec.rb:64:in `block (2 levels) in <main>'

  43) ChequeEntries::VoidActivity should void the cheque for voucher with single cheque entry and bill with full amount
      Failure/Error: cheque_entry = create(:cheque_entry, status: :approved, amount: 5000, branch_id: 1)

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist, Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/void_activity_spec.rb:91:in `block (2 levels) in <main>'

  44) ChequeEntries::VoidActivity should void the cheque for voucher with single cheque entry and bill with partial amount
      Failure/Error: cheque_entry = create(:cheque_entry, status: :approved, amount: 5000, branch_id: 1)

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist, Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/void_activity_spec.rb:118:in `block (2 levels) in <main>'

  45) ChequeEntries::VoidActivity should void the cheque for voucher with multi cheque entry and bills
      Failure/Error: cheque_entry = create(:cheque_entry, status: :approved, amount: 5000, branch_id: 1)

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist, Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/void_activity_spec.rb:145:in `block (2 levels) in <main>'

  46) ChequeEntries::VoidActivity invalid fiscal year should return error if fycode is different than current
      Failure/Error: subject { create(:cheque_entry) }

      ActiveRecord::RecordInvalid:
        Validation failed: Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/void_activity_spec.rb:13:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/void_activity_spec.rb:19:in `block (3 levels) in <main>'

  47) ChequeEntries::VoidActivity receipt cheque should not void receipt cheque
      Failure/Error: subject { create(:cheque_entry) }

      ActiveRecord::RecordInvalid:
        Validation failed: Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/void_activity_spec.rb:13:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/void_activity_spec.rb:28:in `block (3 levels) in <main>'

  48) ChequeEntries::VoidActivity unassigned cheque should void cheque
      Failure/Error: subject { create(:cheque_entry) }

      ActiveRecord::RecordInvalid:
        Validation failed: Additional bank must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/cheque_entries/void_activity_spec.rb:13:in `block (2 levels) in <main>'
      # ./spec/models/cheque_entries/void_activity_spec.rb:37:in `block (3 levels) in <main>'

  49) ClientAccount.change_ledger_name updates the ledger name on client account update
      Failure/Error: expect(client_account.ledger.name).to eq("John")

        expected: "John"
             got: "Dedra Sorenson"

        (compared using ==)
      # ./spec/models/client_account_spec.rb:103:in `block (3 levels) in <main>'

  50) ClientAccount.check_client_branch when branch not changed should check client's branch
      Failure/Error: subject { create(:client_account, name: "John", branch_id: 1) }

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/client_account_spec.rb:170:in `block (3 levels) in <main>'
      # ./spec/models/client_account_spec.rb:171:in `block (3 levels) in <main>'

  51) ClientAccount.check_client_branch when branch changed should return true
      Failure/Error: subject { create(:client_account, name: "John", branch_id: 1) }

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/client_account_spec.rb:170:in `block (3 levels) in <main>'
      # ./spec/models/client_account_spec.rb:171:in `block (3 levels) in <main>'

  52) ClientAccount.create_ledger when nepse code is present should assign client to clients group
      Failure/Error: client_group = Group.find_or_create_by!(name: "Clients")

      ActiveRecord::RecordInvalid:
        Validation failed: Creator must exist, Updater must exist
      # ./spec/models/client_account_spec.rb:221:in `block (4 levels) in <main>'

  53) ClientAccount.assign group should append client ledger to client group ledger
      Failure/Error: expect(client_account.assign_group).to include(Ledger.last)
        expected nil to include #<Ledger id: 115, name: "Dedra Sorenson", client_code: "NEPSE-65", creator_id: nil, updater_id: nil, ...id: nil, client_account_id: 33, employee_account_id: nil, vendor_account_id: nil, restricted: false>, but it does not respond to `include?`
      # ./spec/models/client_account_spec.rb:239:in `block (3 levels) in <main>'

  54) ClientAccount.get_current_valuation should get sum of floorsheet_blnc and isin_info last_price
      Failure/Error: let(:share_inventory) { create(:share_inventory, isin_info: isin_info, floorsheet_blnc: 5, current_user_id: User.first.id, branch_id: 1) }

      ActiveRecord::RecordInvalid:
        Validation failed: Client account must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/client_account_spec.rb:245:in `block (3 levels) in <main>'
      # ./spec/models/client_account_spec.rb:247:in `block (3 levels) in <main>'
      # ./spec/models/client_account_spec.rb:250:in `block (3 levels) in <main>'

  55) ClientAccount.move_particulars should'nt move particulars when branch not changed
      Failure/Error: subject { create(:client_account, name: "John", branch_id: 1) }

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/client_account_spec.rb:518:in `block (3 levels) in <main>'
      # ./spec/models/client_account_spec.rb:529:in `block (3 levels) in <main>'

  56) EmployeeAccount validations is expected to validate that :email is case-sensitively unique
      Failure/Error: it { should validate_uniqueness_of(:email)}

        Expected EmployeeAccount to validate that :email is case-sensitively
        unique, but this could not be proved.
          After taking the given EmployeeAccount, whose :email is
          ‹"test@example.com"›, and saving it as the existing record, then
          making a new EmployeeAccount and setting its :email to
          ‹"test@example.com"› as well, the matcher expected the new
          EmployeeAccount to be invalid, but it was valid instead.
      # ./spec/models/employee_account_spec.rb:12:in `block (3 levels) in <main>'

  57) EmployeeAccount.create_ledger should create a ledger with same name
      Failure/Error: expect(Ledger.where(employee_account_id: subject.id).first.name).to eq(subject.name)

      NoMethodError:
        undefined method `name' for nil:NilClass
      # ./spec/models/employee_account_spec.rb:20:in `block (3 levels) in <main>'

  58) EmployeeAccount#find_similar_to_term when search term is present should return attributes of employee similar to term
      Failure/Error: employee_group = Group.find_or_create_by!(name: "Employees")

      ActiveRecord::RecordInvalid:
        Validation failed: Creator must exist, Updater must exist
      # ./app/models/employee_account.rb:72:in `create_ledger'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/employee_account_spec.rb:31:in `block (4 levels) in <main>'
      # ./spec/models/employee_account_spec.rb:33:in `block (4 levels) in <main>'

  59) EmployeeAccount.name_with_id should append id with name
      Failure/Error: employee_group = Group.find_or_create_by!(name: "Employees")

      ActiveRecord::RecordInvalid:
        Validation failed: Creator must exist, Updater must exist
      # ./app/models/employee_account.rb:72:in `create_ledger'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/employee_account_spec.rb:51:in `block (3 levels) in <main>'
      # ./spec/models/employee_account_spec.rb:53:in `block (3 levels) in <main>'

  60) EmployeeLedgerAssociation#delete_previous_associations_for should destroy all previous associations
      Failure/Error: let(:employee_account){create(:employee_account)}

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/employee_ledger_association_spec.rb:7:in `block (3 levels) in <main>'
      # ./spec/models/employee_ledger_association_spec.rb:8:in `block (3 levels) in <main>'
      # ./spec/models/employee_ledger_association_spec.rb:10:in `block (3 levels) in <main>'

  61) LedgerBalance.update_opening_closing_balance when opening balance is not blank should return negative opening balance
      Failure/Error: subject.cr!

      ActiveRecord::RecordInvalid:
        Validation failed: Ledger must exist
      # ./spec/models/ledger_balance_spec.rb:14:in `block (4 levels) in <main>'

  62) LedgerBalance.update_opening_closing_balance when opening balance is changed when opening balance type is dr should return closing balance
      Failure/Error: subject{create(:ledger_balance)}

      ActiveRecord::RecordInvalid:
        Validation failed: Ledger must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/ledger_balance_spec.rb:31:in `block (5 levels) in <main>'
      # ./spec/models/ledger_balance_spec.rb:33:in `block (5 levels) in <main>'

  63) LedgerBalance.update_opening_closing_balance when opening balance is changed when opening balance type is cr should return closing balance
      Failure/Error: subject{create(:ledger_balance, opening_balance: 3000)}

      ActiveRecord::RecordInvalid:
        Validation failed: Ledger must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/ledger_balance_spec.rb:43:in `block (5 levels) in <main>'
      # ./spec/models/ledger_balance_spec.rb:45:in `block (5 levels) in <main>'

  64) LedgerBalance#update_or_create_org_balance when org balance is not present should create org balance
      Failure/Error: ledger_balance_org = LedgerBalance.unscoped.by_fy_code(fy_code).find_or_create_by!(ledger_id: ledger_id, branch_id: nil, &set_current_user)

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist
      # ./app/models/ledger_balance.rb:87:in `update_or_create_org_balance'
      # ./spec/models/ledger_balance_spec.rb:84:in `block (5 levels) in <main>'
      # ./spec/models/ledger_balance_spec.rb:84:in `block (4 levels) in <main>'

  65) LedgerBalance#update_or_create_org_balance when org balance is present should update org balance
      Failure/Error: subject(:ledger_balance){create(:ledger_balance, ledger: ledger, branch_id: nil)}

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/ledger_balance_spec.rb:78:in `block (3 levels) in <main>'
      # ./spec/models/ledger_balance_spec.rb:91:in `block (4 levels) in <main>'

  66) Ledger.save_custom when valid and params is nil should create ledger balance for org
      Failure/Error: expect { ledger.save_custom(nil, 7374, @branch.id) }.to change {LedgerBalance.unscoped.count }.by(3)
        expected `LedgerBalance.unscoped.count` to have changed by 3, but was changed by 0
      # ./spec/models/ledger_spec.rb:140:in `block (5 levels) in <main>'

  67) Ledger.save_custom when valid and params is present should update ledger balance for org
      Failure/Error: ledger.ledger_balances "<<" create(:ledger_balance, branch_id: 2, opening_balance: "5000", current_user_id: User.first.id)

      ActiveRecord::RecordInvalid:
        Validation failed: Ledger must exist, Branch must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/ledger_spec.rb:148:in `block (5 levels) in <main>'

  68) Ledger.closing_balance when session branch is head office and ledger has activities should return correct closing balance
      Failure/Error: create(:ledger_balance, ledger: subject, fy_code: 7374, branch_id: nil, opening_balance: 5000, current_user_id: User.first.id)

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/ledger_spec.rb:206:in `block (5 levels) in <main>'

  69) Ledger.closing_balance when session branch is branch office should return closing balance
      Failure/Error: create(:ledger_balance, ledger: subject, fy_code: 7374, branch_id: 1, opening_balance: 3000)

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/ledger_spec.rb:221:in `block (4 levels) in <main>'

  70) Ledger#find_similar_to_term when search term is present when employee account id is present should return attributes for employee account
      Failure/Error: let(:employee_account){create(:employee_account, name: "john")}

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/ledger_spec.rb:321:in `block (5 levels) in <main>'
      # ./spec/models/ledger_spec.rb:324:in `block (5 levels) in <main>'

  71) Ledger.name_and_identifier when employee account id is present should return name and identifier for employee account
      Failure/Error: let(:employee_account){create(:employee_account, name: "john")}

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/ledger_spec.rb:375:in `block (4 levels) in <main>'
      # ./spec/models/ledger_spec.rb:378:in `block (4 levels) in <main>'

  72) Ledger.delete_associated_records should delete ledger balance
      Failure/Error: let(:ledger_balance){create(:ledger_balance)}

      ActiveRecord::RecordInvalid:
        Validation failed: Ledger must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/ledger_spec.rb:406:in `block (3 levels) in <main>'
      # ./spec/models/ledger_spec.rb:410:in `block (3 levels) in <main>'

  73) Ledger.delete_associated_records should delete ledger daily
      Failure/Error: let(:ledger_daily){create(:ledger_daily, date: Date.today)}

      ActiveRecord::RecordInvalid:
        Validation failed: Ledger must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/ledger_spec.rb:407:in `block (3 levels) in <main>'
      # ./spec/models/ledger_spec.rb:417:in `block (3 levels) in <main>'

  74) Ledgers::ParticularEntry.calculate_balances when accounting date is before date and debit adds dr_amount and increments closing balance for ledger dailies for that day
      Failure/Error: daily_report_org = LedgerDaily.by_fy_code_org(fy_code).find_or_create_by!(ledger_id: ledger.id, date: date, &set_current_user_id)

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:48:in `block (2 levels) in patch_ledger_dailies'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:34:in `each'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:34:in `block in patch_ledger_dailies'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:24:in `each'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:24:in `patch_ledger_dailies'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:77:in `block in process'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:76:in `process'
      # ./spec/models/ledgers/particular_entry_spec.rb:27:in `block (3 levels) in <main>'
      # ./spec/models/ledgers/particular_entry_spec.rb:26:in `each'
      # ./spec/models/ledgers/particular_entry_spec.rb:26:in `block (2 levels) in <main>'

  75) Ledgers::ParticularEntry.calculate_balances when accounting date is before date and debit adds dr_amount and increments closing balance for ledger balances for that day
      Failure/Error: daily_report_org = LedgerDaily.by_fy_code_org(fy_code).find_or_create_by!(ledger_id: ledger.id, date: date, &set_current_user_id)

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:48:in `block (2 levels) in patch_ledger_dailies'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:34:in `each'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:34:in `block in patch_ledger_dailies'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:24:in `each'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:24:in `patch_ledger_dailies'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:77:in `block in process'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:76:in `process'
      # ./spec/models/ledgers/particular_entry_spec.rb:27:in `block (3 levels) in <main>'
      # ./spec/models/ledgers/particular_entry_spec.rb:26:in `each'
      # ./spec/models/ledgers/particular_entry_spec.rb:26:in `block (2 levels) in <main>'

  76) Ledgers::ParticularEntry.calculate_balances when accounting date is before date and debit carries the dr_amount, opening balance and closing balance to the future dates
      Failure/Error: daily_report_org = LedgerDaily.by_fy_code_org(fy_code).find_or_create_by!(ledger_id: ledger.id, date: date, &set_current_user_id)

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:48:in `block (2 levels) in patch_ledger_dailies'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:34:in `each'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:34:in `block in patch_ledger_dailies'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:24:in `each'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:24:in `patch_ledger_dailies'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:77:in `block in process'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:76:in `process'
      # ./spec/models/ledgers/particular_entry_spec.rb:27:in `block (3 levels) in <main>'
      # ./spec/models/ledgers/particular_entry_spec.rb:26:in `each'
      # ./spec/models/ledgers/particular_entry_spec.rb:26:in `block (2 levels) in <main>'

  77) Ledgers::ParticularEntry.calculate_balances when accounting date is before date and credit adds cr_amount and decrements closing balance for ledger dailies for that day
      Failure/Error: daily_report_org = LedgerDaily.by_fy_code_org(fy_code).find_or_create_by!(ledger_id: ledger.id, date: date, &set_current_user_id)

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:48:in `block (2 levels) in patch_ledger_dailies'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:34:in `each'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:34:in `block in patch_ledger_dailies'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:24:in `each'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:24:in `patch_ledger_dailies'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:77:in `block in process'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:76:in `process'
      # ./spec/models/ledgers/particular_entry_spec.rb:27:in `block (3 levels) in <main>'
      # ./spec/models/ledgers/particular_entry_spec.rb:26:in `each'
      # ./spec/models/ledgers/particular_entry_spec.rb:26:in `block (2 levels) in <main>'

  78) Ledgers::ParticularEntry.calculate_balances when accounting date is before date and credit adds cr_amount and decrements  closing balance for ledger balances for that day
      Failure/Error: daily_report_org = LedgerDaily.by_fy_code_org(fy_code).find_or_create_by!(ledger_id: ledger.id, date: date, &set_current_user_id)

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:48:in `block (2 levels) in patch_ledger_dailies'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:34:in `each'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:34:in `block in patch_ledger_dailies'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:24:in `each'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:24:in `patch_ledger_dailies'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:77:in `block in process'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:76:in `process'
      # ./spec/models/ledgers/particular_entry_spec.rb:27:in `block (3 levels) in <main>'
      # ./spec/models/ledgers/particular_entry_spec.rb:26:in `each'
      # ./spec/models/ledgers/particular_entry_spec.rb:26:in `block (2 levels) in <main>'

  79) Ledgers::ParticularEntry.calculate_balances when accounting date is before date and credit carries the cr_amount, opening balance and closing balance to the future dates
      Failure/Error: daily_report_org = LedgerDaily.by_fy_code_org(fy_code).find_or_create_by!(ledger_id: ledger.id, date: date, &set_current_user_id)

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:48:in `block (2 levels) in patch_ledger_dailies'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:34:in `each'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:34:in `block in patch_ledger_dailies'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:24:in `each'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:24:in `patch_ledger_dailies'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:77:in `block in process'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:76:in `process'
      # ./spec/models/ledgers/particular_entry_spec.rb:27:in `block (3 levels) in <main>'
      # ./spec/models/ledgers/particular_entry_spec.rb:26:in `each'
      # ./spec/models/ledgers/particular_entry_spec.rb:26:in `block (2 levels) in <main>'

  80) Ledgers::ParticularEntry.calculate_balances when accounting date is after date and debit creates new ledger dailies for that day
      Failure/Error: daily_report_org = LedgerDaily.by_fy_code_org(fy_code).find_or_create_by!(ledger_id: ledger.id, date: date, &set_current_user_id)

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:48:in `block (2 levels) in patch_ledger_dailies'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:34:in `each'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:34:in `block in patch_ledger_dailies'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:24:in `each'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:24:in `patch_ledger_dailies'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:77:in `block in process'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:76:in `process'
      # ./spec/models/ledgers/particular_entry_spec.rb:27:in `block (3 levels) in <main>'
      # ./spec/models/ledgers/particular_entry_spec.rb:26:in `each'
      # ./spec/models/ledgers/particular_entry_spec.rb:26:in `block (2 levels) in <main>'

  81) Ledgers::ParticularEntry.calculate_balances when accounting date is after date and debit adds dr_amount and increments closing balance for ledger balances for that day
      Failure/Error: daily_report_org = LedgerDaily.by_fy_code_org(fy_code).find_or_create_by!(ledger_id: ledger.id, date: date, &set_current_user_id)

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:48:in `block (2 levels) in patch_ledger_dailies'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:34:in `each'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:34:in `block in patch_ledger_dailies'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:24:in `each'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:24:in `patch_ledger_dailies'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:77:in `block in process'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:76:in `process'
      # ./spec/models/ledgers/particular_entry_spec.rb:27:in `block (3 levels) in <main>'
      # ./spec/models/ledgers/particular_entry_spec.rb:26:in `each'
      # ./spec/models/ledgers/particular_entry_spec.rb:26:in `block (2 levels) in <main>'

  82) Ledgers::ParticularEntry.calculate_balances when accounting date is after date and credit creates new ledger dailies for that day
      Failure/Error: daily_report_org = LedgerDaily.by_fy_code_org(fy_code).find_or_create_by!(ledger_id: ledger.id, date: date, &set_current_user_id)

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:48:in `block (2 levels) in patch_ledger_dailies'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:34:in `each'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:34:in `block in patch_ledger_dailies'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:24:in `each'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:24:in `patch_ledger_dailies'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:77:in `block in process'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:76:in `process'
      # ./spec/models/ledgers/particular_entry_spec.rb:27:in `block (3 levels) in <main>'
      # ./spec/models/ledgers/particular_entry_spec.rb:26:in `each'
      # ./spec/models/ledgers/particular_entry_spec.rb:26:in `block (2 levels) in <main>'

  83) Ledgers::ParticularEntry.calculate_balances when accounting date is after date and credit adds cr_amount and decrements closing balance for ledger balances for that day
      Failure/Error: daily_report_org = LedgerDaily.by_fy_code_org(fy_code).find_or_create_by!(ledger_id: ledger.id, date: date, &set_current_user_id)

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:48:in `block (2 levels) in patch_ledger_dailies'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:34:in `each'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:34:in `block in patch_ledger_dailies'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:24:in `each'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:24:in `patch_ledger_dailies'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:77:in `block in process'
      # ./app/services/accounts/ledgers/populate_ledger_dailies_service.rb:76:in `process'
      # ./spec/models/ledgers/particular_entry_spec.rb:27:in `block (3 levels) in <main>'
      # ./spec/models/ledgers/particular_entry_spec.rb:26:in `each'
      # ./spec/models/ledgers/particular_entry_spec.rb:26:in `block (2 levels) in <main>'

  84) MenuItem#black_listed_paths_for_user should return black listed path
      Failure/Error: let(:menu_permission){create(:menu_permission, user_access_role: user_access_role)}

      ActiveRecord::RecordInvalid:
        Validation failed: Creator must exist, Updater must exist, Menu item must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/menu_item_spec.rb:15:in `block (3 levels) in <main>'
      # ./spec/models/menu_item_spec.rb:19:in `block (3 levels) in <main>'

  85) NepseSettlement.bills_for_payment_letter_list when require processing is true when net amount is greater than 0 should return bill
      Failure/Error: expect(subject.bills_for_payment_letter_list(branch.id)).to eq([bill1])

        expected: [#<Bill id: 15, bill_number: 41, client_name: "Harold Hill", net_amount: 0.3e4, balance_to_pay: 0.3e4...h_id: 645, nepse_settlement_id: nil, settlement_approval_status: "incognito", closeout_charge: 0.0>]
             got: []

        (compared using ==)

        Diff:
        @@ -1 +1 @@
        -[#<Bill id: 15, bill_number: 41, client_name: "Harold Hill", net_amount: 0.3e4, balance_to_pay: 0.3e4, bill_type: "purchase", status: "pending", special_case: "regular", created_at: "2020-11-08 14:55:49", updated_at: "2020-11-08 14:55:49", fy_code: 7374, date: "2020-11-05", date_bs: "2077-07-20", settlement_date: "2020-11-08", client_account_id: 52, creator_id: 426, updater_id: 426, branch_id: 645, nepse_settlement_id: nil, settlement_approval_status: "incognito", closeout_charge: 0.0>]
        +[]
      # ./spec/models/nepse_settlement_spec.rb:18:in `block (5 levels) in <main>'

  86) NepseSettlement.bills_for_sales_payment_list when require processing is true and net amount is greater than 0 should return bill for sale payment
      Failure/Error: expect(subject.bills_for_sales_payment_list(branch.id)).to eq([bill])

        expected: [#<Bill id: 18, bill_number: 44, client_name: "Harold Hill", net_amount: 0.2e4, balance_to_pay: 0.2e4...h_id: 657, nepse_settlement_id: nil, settlement_approval_status: "incognito", closeout_charge: 0.0>]
             got: []

        (compared using ==)

        Diff:
        @@ -1 +1 @@
        -[#<Bill id: 18, bill_number: 44, client_name: "Harold Hill", net_amount: 0.2e4, balance_to_pay: 0.2e4, bill_type: "purchase", status: "pending", special_case: "regular", created_at: "2020-11-08 14:55:50", updated_at: "2020-11-08 14:55:50", fy_code: 7374, date: "2020-11-05", date_bs: "2077-07-20", settlement_date: "2020-11-08", client_account_id: 55, creator_id: 429, updater_id: 429, branch_id: 657, nepse_settlement_id: nil, settlement_approval_status: "incognito", closeout_charge: 0.0>]
        +[]
      # ./spec/models/nepse_settlement_spec.rb:53:in `block (5 levels) in <main>'

  87) OrderRequestDetail.can be updated? should return true for pending status
      Failure/Error: subject{create(:order_request_detail, status: 0, isin_info_id: isin_info.id, order_type: 1, order_request_id: order_request.id )}

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/order_request_detail_spec.rb:9:in `block (2 levels) in <main>'
      # ./spec/models/order_request_detail_spec.rb:14:in `block (3 levels) in <main>'

  88) OrderRequestDetail.soft_delete should update_status to cancelled
      Failure/Error: subject{create(:order_request_detail, status: 0, isin_info_id: isin_info.id, order_type: 1, order_request_id: order_request.id )}

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/order_request_detail_spec.rb:9:in `block (2 levels) in <main>'
      # ./spec/models/order_request_detail_spec.rb:21:in `block (4 levels) in <main>'
      # ./spec/models/order_request_detail_spec.rb:21:in `block (3 levels) in <main>'

  89) OrderRequestDetail.as_json adds method to json response
      Failure/Error: subject{create(:order_request_detail, status: 0, isin_info_id: isin_info.id, order_type: 1, order_request_id: order_request.id )}

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/order_request_detail_spec.rb:9:in `block (2 levels) in <main>'
      # ./spec/models/order_request_detail_spec.rb:29:in `block (3 levels) in <main>'

  90) OrderRequestDetail test scopes #sorted_by when sort option is desc should order 'order request details' by descending
      Failure/Error: let(:todays_order){create(:order_request_detail, status: 0, isin_info_id: isin_info.id, order_type: 1, order_request_id: order_request.id, created_at: Time.now.beginning_of_day )}

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/order_request_detail_spec.rb:38:in `block (3 levels) in <main>'
      # ./spec/models/order_request_detail_spec.rb:44:in `block (5 levels) in <main>'

  91) Settlement#new_settlement_number when settlement is present should get new settlement number
      Failure/Error: subject{create(:settlement, branch_id: 1, settlement_type: 0, date_bs: "2074-03-05", fy_code: 7374)}

      ActiveRecord::RecordInvalid:
        Validation failed: Creator must exist, Updater must exist, Branch must exist, Voucher must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/settlement_spec.rb:45:in `block (4 levels) in <main>'
      # ./spec/models/settlement_spec.rb:47:in `block (4 levels) in <main>'

  92) ShareTransaction.as_json adds method to json response
      Failure/Error: subject{create(:share_transaction, isin_info_id:isin_info.id, client_account_id: client_account.id)}

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist, Voucher must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/share_transaction_spec.rb:15:in `block (3 levels) in <main>'
      # ./spec/models/share_transaction_spec.rb:17:in `block (3 levels) in <main>'

  93) ShareTransaction.available_balancing_transactions returns available balancing transaction
      Failure/Error: create(:share_transaction, isin_info_id:isin_info.id, client_account_id: client_account.id, transaction_type: 0, date: "2016-12-28")

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist, Voucher must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/share_transaction_spec.rb:29:in `block (3 levels) in <main>'

  94) ShareTransaction.soft_delete returns true
      Failure/Error: subject{create(:share_transaction)}

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist, Voucher must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/share_transaction_spec.rb:53:in `block (3 levels) in <main>'
      # ./spec/models/share_transaction_spec.rb:55:in `block (3 levels) in <main>'

  95) ShareTransaction.soft_undelete returns true
      Failure/Error: subject{create(:share_transaction)}

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist, Voucher must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/share_transaction_spec.rb:61:in `block (3 levels) in <main>'
      # ./spec/models/share_transaction_spec.rb:63:in `block (3 levels) in <main>'

  96) ShareTransaction.update_with_base_price updates with base price
      Failure/Error: subject{create(:share_transaction, cgt: 5000, base_price: 2000, quantity: 100, share_rate: 600, net_amount: 10000)}

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist, Voucher must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/share_transaction_spec.rb:69:in `block (3 levels) in <main>'
      # ./spec/models/share_transaction_spec.rb:71:in `block (3 levels) in <main>'

  97) ShareTransaction.calculate_cgt when cgt var is less than 0 calculates cgt
      Failure/Error: subject{create(:share_transaction, cgt: 5000, base_price: 2000, quantity: 100, share_rate: 600, net_amount: 10000)}

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist, Voucher must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/share_transaction_spec.rb:80:in `block (4 levels) in <main>'
      # ./spec/models/share_transaction_spec.rb:82:in `block (4 levels) in <main>'

  98) ShareTransaction.calculate_cgt when cgt var isnot less than 0 calculates cgt
      Failure/Error: subject{create(:share_transaction, cgt: 5000, base_price: 200, quantity: 100, share_rate: 600, net_amount: 10000)}

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist, Voucher must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/share_transaction_spec.rb:87:in `block (4 levels) in <main>'
      # ./spec/models/share_transaction_spec.rb:89:in `block (4 levels) in <main>'

  99) ShareTransaction.stock_commission_amount returns stock commission amount
      Failure/Error: subject{create(:share_transaction, commission_amount: 500)}

      ActiveRecord::RecordInvalid:
        Validation failed: Branch must exist, Voucher must exist
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
      # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
      # ./spec/models/share_transaction_spec.rb:123:in `block (3 levels) in <main>'
      # ./spec/models/share_transaction_spec.rb:126:in `block (3 levels) in <main>'

  100) ShareTransaction.counter_broker when transaction type is buying returns broker no.
       Failure/Error: subject.buying!

       ActiveRecord::RecordInvalid:
         Validation failed: Branch must exist, Voucher must exist
       # ./spec/models/share_transaction_spec.rb:133:in `block (4 levels) in <main>'

  101) ShareTransaction.counter_broker when transaction type is not buying returns broker no.
       Failure/Error: subject.selling!

       ActiveRecord::RecordInvalid:
         Validation failed: Branch must exist, Voucher must exist
       # ./spec/models/share_transaction_spec.rb:140:in `block (4 levels) in <main>'

  102) Voucher.map_payment_receipt_to_new_types when voucher type is receipt and cheque entries count is greater than 0 returns voucher type as receipt bank
       Failure/Error: let!(:cheque_entry1){create(:cheque_entry)}

       ActiveRecord::RecordInvalid:
         Validation failed: Additional bank must exist
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
       # ./spec/models/voucher_spec.rb:220:in `block (4 levels) in <main>'

  103) Voucher.map_payment_receipt_to_new_types when voucher type is receipt and cheque entries count is not greater than 0 returns voucher type as receipt cash
       Failure/Error: let!(:cheque_entry1){create(:cheque_entry)}

       ActiveRecord::RecordInvalid:
         Validation failed: Additional bank must exist
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
       # ./spec/models/voucher_spec.rb:220:in `block (4 levels) in <main>'

  104) Voucher.map_payment_receipt_to_new_types when voucher type is payment and cheque entries count is greater than 0 returns voucher type as payment bank
       Failure/Error: let!(:cheque_entry1){create(:cheque_entry)}

       ActiveRecord::RecordInvalid:
         Validation failed: Additional bank must exist
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
       # ./spec/models/voucher_spec.rb:241:in `block (4 levels) in <main>'

  105) Voucher.map_payment_receipt_to_new_types when voucher type is payment and cheque entries count is not greater than 0 returns voucher type as payment cash
       Failure/Error: let!(:cheque_entry1){create(:cheque_entry)}

       ActiveRecord::RecordInvalid:
         Validation failed: Additional bank must exist
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
       # ./spec/models/voucher_spec.rb:241:in `block (4 levels) in <main>'

  106) Voucher.assign_cheque when voucher is payment voucher assigns cheque
       Failure/Error: let!(:cheque_entry){create(:cheque_entry)}

       ActiveRecord::RecordInvalid:
         Validation failed: Additional bank must exist
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
       # ./spec/models/voucher_spec.rb:338:in `block (3 levels) in <main>'

  107) Voucher.assign_cheque when voucher is payment voucher and cheque_beneficiary name is not present should assign beneficiary name from first dr particular
       Failure/Error: let!(:cheque_entry){create(:cheque_entry)}

       ActiveRecord::RecordInvalid:
         Validation failed: Additional bank must exist
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
       # ./spec/models/voucher_spec.rb:338:in `block (3 levels) in <main>'

  108) Voucher.assign_cheque when voucher is payment voucher and internal bank payments should assign beneficiary name to both cheques as company
       Failure/Error: let!(:cheque_entry){create(:cheque_entry)}

       ActiveRecord::RecordInvalid:
         Validation failed: Additional bank must exist
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
       # ./spec/models/voucher_spec.rb:338:in `block (3 levels) in <main>'

  109) Voucher.assign_cheque when voucher is receipt voucher assigns cheque
       Failure/Error: let!(:cheque_entry){create(:cheque_entry)}

       ActiveRecord::RecordInvalid:
         Validation failed: Additional bank must exist
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
       # ./spec/models/voucher_spec.rb:338:in `block (3 levels) in <main>'

  110) Voucher.assign_cheque when voucher is receipt voucher and cheque_beneficiary name is not present should assign beneficiary name from first cr particular
       Failure/Error: let!(:cheque_entry){create(:cheque_entry)}

       ActiveRecord::RecordInvalid:
         Validation failed: Additional bank must exist
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
       # ./spec/models/voucher_spec.rb:338:in `block (3 levels) in <main>'

  111) Vouchers::Base.set_bill_client should return error when other bill ids are sent
       Failure/Error: expect { @assert_smartkhata_error.call(voucher_base, client_account_id, bill_ids, false) }.to raise_error(SmartKhataError)
         expected SmartKhataError but nothing was raised
       # ./spec/models/vouchers/base_spec.rb:178:in `block (3 levels) in <main>'

  112) Vouchers::Create vouchers when journal voucher when particular description is not present should display voucher narration
       Failure/Error: cash_ledger_id = Ledger.find_by(name: "Cash").id

       NoMethodError:
         undefined method `id' for nil:NilClass
       # ./app/models/vouchers/create.rb:146:in `process_particulars'
       # ./app/models/vouchers/create.rb:116:in `process'
       # ./spec/models/vouchers/create_spec.rb:45:in `block (5 levels) in <main>'

  113) Vouchers::Create vouchers when journal voucher when particular description is  present should display particular description
       Failure/Error: cash_ledger_id = Ledger.find_by(name: "Cash").id

       NoMethodError:
         undefined method `id' for nil:NilClass
       # ./app/models/vouchers/create.rb:146:in `process_particulars'
       # ./app/models/vouchers/create.rb:116:in `process'
       # ./spec/models/vouchers/create_spec.rb:65:in `block (5 levels) in <main>'

  114) Vouchers::Create vouchers when payment voucher when particular description is not present should display voucher narration
       Failure/Error: cash_ledger_id = Ledger.find_by(name: "Cash").id

       NoMethodError:
         undefined method `id' for nil:NilClass
       # ./app/models/vouchers/create.rb:146:in `process_particulars'
       # ./app/models/vouchers/create.rb:116:in `process'
       # ./spec/models/vouchers/create_spec.rb:88:in `block (5 levels) in <main>'

  115) Vouchers::Create vouchers when payment voucher when particular description is  present should display particular description
       Failure/Error: cash_ledger_id = Ledger.find_by(name: "Cash").id

       NoMethodError:
         undefined method `id' for nil:NilClass
       # ./app/models/vouchers/create.rb:146:in `process_particulars'
       # ./app/models/vouchers/create.rb:116:in `process'
       # ./spec/models/vouchers/create_spec.rb:108:in `block (5 levels) in <main>'

  116) Vouchers::Create vouchers when receipt voucher when particular description is not present should display voucher narration
       Failure/Error: cash_ledger_id = Ledger.find_by(name: "Cash").id

       NoMethodError:
         undefined method `id' for nil:NilClass
       # ./app/models/vouchers/create.rb:146:in `process_particulars'
       # ./app/models/vouchers/create.rb:116:in `process'
       # ./spec/models/vouchers/create_spec.rb:130:in `block (5 levels) in <main>'

  117) Vouchers::Create vouchers when receipt voucher when particular description is  present should display particular description
       Failure/Error: cash_ledger_id = Ledger.find_by(name: "Cash").id

       NoMethodError:
         undefined method `id' for nil:NilClass
       # ./app/models/vouchers/create.rb:146:in `process_particulars'
       # ./app/models/vouchers/create.rb:116:in `process'
       # ./spec/models/vouchers/create_spec.rb:150:in `block (5 levels) in <main>'

  118) Vouchers::Create basic vouchers should create a journal voucher
       Failure/Error: cash_ledger_id = Ledger.find_by(name: "Cash").id

       NoMethodError:
         undefined method `id' for nil:NilClass
       # ./app/models/vouchers/create.rb:146:in `process_particulars'
       # ./app/models/vouchers/create.rb:116:in `process'
       # ./spec/models/vouchers/create_spec.rb:171:in `block (3 levels) in <main>'

  119) Vouchers::Create basic vouchers should create a payment voucher
       Failure/Error: cash_ledger_id = Ledger.find_by(name: "Cash").id

       NoMethodError:
         undefined method `id' for nil:NilClass
       # ./app/models/vouchers/create.rb:146:in `process_particulars'
       # ./app/models/vouchers/create.rb:116:in `process'
       # ./spec/models/vouchers/create_spec.rb:188:in `block (3 levels) in <main>'

  120) Vouchers::Create basic vouchers should create a receipt voucher
       Failure/Error: cash_ledger_id = Ledger.find_by(name: "Cash").id

       NoMethodError:
         undefined method `id' for nil:NilClass
       # ./app/models/vouchers/create.rb:146:in `process_particulars'
       # ./app/models/vouchers/create.rb:116:in `process'
       # ./spec/models/vouchers/create_spec.rb:205:in `block (3 levels) in <main>'

  121) Vouchers::Create duplicate cheque entry should not create receipt voucher with duplicate cheque entry
       Failure/Error: cash_ledger_id = Ledger.find_by(name: "Cash").id

       NoMethodError:
         undefined method `id' for nil:NilClass
       # ./app/models/vouchers/create.rb:146:in `process_particulars'
       # ./app/models/vouchers/create.rb:116:in `process'
       # ./spec/models/vouchers/create_spec.rb:227:in `block (3 levels) in <main>'

  122) Vouchers::Create duplicate cheque entry should create receipt voucher for bounced cheque entry
       Failure/Error: cash_ledger_id = Ledger.find_by(name: "Cash").id

       NoMethodError:
         undefined method `id' for nil:NilClass
       # ./app/models/vouchers/create.rb:146:in `process_particulars'
       # ./app/models/vouchers/create.rb:116:in `process'
       # ./spec/models/vouchers/create_spec.rb:261:in `block (3 levels) in <main>'

  123) Vouchers::Create complex receipt vouchers should settle purchase bill with full amount
       Failure/Error: cash_ledger_id = Ledger.find_by(name: "Cash").id

       NoMethodError:
         undefined method `id' for nil:NilClass
       # ./app/models/vouchers/create.rb:146:in `process_particulars'
       # ./app/models/vouchers/create.rb:116:in `process'
       # ./spec/models/vouchers/create_spec.rb:302:in `block (3 levels) in <main>'

  124) Vouchers::Create complex receipt vouchers should partially settle purchase bill with partial amount
       Failure/Error: cash_ledger_id = Ledger.find_by(name: "Cash").id

       NoMethodError:
         undefined method `id' for nil:NilClass
       # ./app/models/vouchers/create.rb:146:in `process_particulars'
       # ./app/models/vouchers/create.rb:116:in `process'
       # ./spec/models/vouchers/create_spec.rb:339:in `block (3 levels) in <main>'

  125) Vouchers::Create complex receipt vouchers should settle purchase bill with ledger having advance amount
       Failure/Error: cash_ledger_id = Ledger.find_by(name: "Cash").id

       NoMethodError:
         undefined method `id' for nil:NilClass
       # ./app/models/vouchers/create.rb:146:in `process_particulars'
       # ./app/models/vouchers/create.rb:116:in `process'
       # ./spec/models/vouchers/create_spec.rb:377:in `block (3 levels) in <main>'

  126) Vouchers::Create complex payment should settle sales bill with full amount
       Failure/Error: cash_ledger_id = Ledger.find_by(name: "Cash").id

       NoMethodError:
         undefined method `id' for nil:NilClass
       # ./app/models/vouchers/create.rb:146:in `process_particulars'
       # ./app/models/vouchers/create.rb:116:in `process'
       # ./spec/models/vouchers/create_spec.rb:411:in `block (3 levels) in <main>'

  127) Vouchers::Create complex payment should partially settle sales bill with partial amount
       Failure/Error: cash_ledger_id = Ledger.find_by(name: "Cash").id

       NoMethodError:
         undefined method `id' for nil:NilClass
       # ./app/models/vouchers/create.rb:146:in `process_particulars'
       # ./app/models/vouchers/create.rb:116:in `process'
       # ./spec/models/vouchers/create_spec.rb:444:in `block (3 levels) in <main>'

  128) Vouchers::Create complex payment should settle sales bill with ledger having advance amount
       Failure/Error: cash_ledger_id = Ledger.find_by(name: "Cash").id

       NoMethodError:
         undefined method `id' for nil:NilClass
       # ./app/models/vouchers/create.rb:146:in `process_particulars'
       # ./app/models/vouchers/create.rb:116:in `process'
       # ./spec/models/vouchers/create_spec.rb:478:in `block (3 levels) in <main>'

  129) Vouchers::Create complex payment and receipt should settle both type of bills
       Failure/Error: cash_ledger_id = Ledger.find_by(name: "Cash").id

       NoMethodError:
         undefined method `id' for nil:NilClass
       # ./app/models/vouchers/create.rb:146:in `process_particulars'
       # ./app/models/vouchers/create.rb:116:in `process'
       # ./spec/models/vouchers/create_spec.rb:513:in `block (3 levels) in <main>'

  130) Vouchers::Create valid branch when non client particulars should return true
       Failure/Error: cash_ledger_id = Ledger.find_by(name: "Cash").id

       NoMethodError:
         undefined method `id' for nil:NilClass
       # ./app/models/vouchers/create.rb:146:in `process_particulars'
       # ./app/models/vouchers/create.rb:116:in `process'
       # ./spec/models/vouchers/create_spec.rb:576:in `block (4 levels) in <main>'

  131) Vouchers::Create valid branch when non client particulars should return true
       Failure/Error: cash_ledger_id = Ledger.find_by(name: "Cash").id

       NoMethodError:
         undefined method `id' for nil:NilClass
       # ./app/models/vouchers/create.rb:146:in `process_particulars'
       # ./app/models/vouchers/create.rb:116:in `process'
       # ./spec/models/vouchers/create_spec.rb:620:in `block (4 levels) in <main>'

  132) Vouchers::Create valid branch when client particular present should return true
       Failure/Error: cash_ledger_id = Ledger.find_by(name: "Cash").id

       NoMethodError:
         undefined method `id' for nil:NilClass
       # ./app/models/vouchers/create.rb:146:in `process_particulars'
       # ./app/models/vouchers/create.rb:116:in `process'
       # ./spec/models/vouchers/create_spec.rb:671:in `block (4 levels) in <main>'

  133) Vouchers::Create valid branch when client particulars with different branch should return true
       Failure/Error: cash_ledger_id = Ledger.find_by(name: "Cash").id

       NoMethodError:
         undefined method `id' for nil:NilClass
       # ./app/models/vouchers/create.rb:146:in `process_particulars'
       # ./app/models/vouchers/create.rb:116:in `process'
       # ./spec/models/vouchers/create_spec.rb:697:in `block (4 levels) in <main>'

  134) Vouchers::Create valid branch when employee particular present should return true
       Failure/Error: employee_group = Group.find_or_create_by!(name: "Employees")

       ActiveRecord::RecordInvalid:
         Validation failed: Creator must exist, Updater must exist
       # ./app/models/employee_account.rb:72:in `create_ledger'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/evaluation.rb:18:in `create'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:12:in `block in result'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `tap'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy/create.rb:9:in `result'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory.rb:43:in `run'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:29:in `block in run'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/factory_runner.rb:28:in `run'
       # /home/cdrrazan/.rvm/gems/ruby-2.6.5/gems/factory_bot-6.1.0/lib/factory_bot/strategy_syntax_method_registrar.rb:28:in `block in define_singular_strategy_method'
       # ./spec/models/vouchers/create_spec.rb:703:in `block (4 levels) in <main>'
       # ./spec/models/vouchers/create_spec.rb:704:in `block (4 levels) in <main>'
       # ./spec/models/vouchers/create_spec.rb:705:in `block (4 levels) in <main>'
       # ./spec/models/vouchers/create_spec.rb:709:in `block (4 levels) in <main>'

  135) Vouchers::Setup basic vouchers should build a payment voucher
       Failure/Error: default_bank_payment ? default_bank_payment.ledger.id : cash_ledger.id

       NoMethodError:
         undefined method `id' for nil:NilClass
       # ./app/models/vouchers/setup.rb:56:in `voucher_setup'
       # ./app/models/vouchers/setup.rb:3:in `voucher_and_relevant'
       # ./spec/models/vouchers/setup_spec.rb:35:in `block (3 levels) in <main>'

  136) Vouchers::Setup basic vouchers should build a receipt voucher
       Failure/Error: default_bank_receive ? default_bank_receive.ledger.id : cash_ledger.id

       NoMethodError:
         undefined method `id' for nil:NilClass
       # ./app/models/vouchers/setup.rb:54:in `voucher_setup'
       # ./app/models/vouchers/setup.rb:3:in `voucher_and_relevant'
       # ./spec/models/vouchers/setup_spec.rb:49:in `block (3 levels) in <main>'

  137) Vouchers::Setup clear ledgers advanced vouchers should build a payment voucher when ledger balance is in cr
       Failure/Error: default_bank_payment ? default_bank_payment.ledger.id : cash_ledger.id

       NoMethodError:
         undefined method `id' for nil:NilClass
       # ./app/models/vouchers/setup.rb:56:in `voucher_setup'
       # ./app/models/vouchers/setup.rb:3:in `voucher_and_relevant'
       # ./spec/models/vouchers/setup_spec.rb:66:in `block (3 levels) in <main>'

  138) Vouchers::Setup clear ledgers advanced vouchers should build a receipt voucher when ledger balance is in dr
       Failure/Error: default_bank_payment ? default_bank_payment.ledger.id : cash_ledger.id

       NoMethodError:
         undefined method `id' for nil:NilClass
       # ./app/models/vouchers/setup.rb:56:in `voucher_setup'
       # ./app/models/vouchers/setup.rb:3:in `voucher_and_relevant'
       # ./spec/models/vouchers/setup_spec.rb:80:in `block (3 levels) in <main>'

