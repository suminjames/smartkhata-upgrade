class MoveClientParticularJob < ActiveJob::Base
  queue_as :default
  def perform(client_account_id, branch_id, updater_id)
    client_account = ClientAccount.find(client_account_id)
    Accounts::Branches::ClientBranchService.new.patch_client_branch(client_account, branch_id, updater_id)
  end
end
