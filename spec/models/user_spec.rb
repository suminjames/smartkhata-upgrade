require 'rails_helper'

RSpec.describe User, type: :model do
  subject {build(:user)}

  describe "validations" do
    it { expect(subject).to be_valid }
    it { should validate_uniqueness_of(:username).case_insensitive }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should allow_value('user123').for(:username) }

    context "email absent but username present" do
      before { allow(subject).to receive(:email).and_return(nil) }
      # it { expect(subject).to be_valid }
      it{ should validate_presence_of(:username)}
    end

    context "username absent but email present" do
      before { allow(subject).to receive(:username).and_return(nil) }
      # it { expect(subject).to be_valid }
      it{ should validate_presence_of(:email)}
    end

    it { should allow_value('user@gmail.com').for(:email) }

    it { should validate_length_of(:password).is_at_most(20) }
    it { should validate_length_of(:password).is_at_least(4) }
    it { should validate_confirmation_of(:password)}
  end

  describe "role" do
    it "allows the role to updated" do
      subject.save
      subject.role = subject.class.roles[:admin]
      expect(subject).to be_valid
    end
  end

  describe ".set_default_role" do
    context "when role is present" do
      it "returns role" do
        subject.role = :client
        expect(subject.set_default_role).to eq("client")
      end
    end

    context "when role isnot present" do
      it "set default role to user" do
        expect(subject.set_default_role).to eq("admin")
      end
    end
  end

  # describe "#client_logged_in?" do
  #   subject{create(:user)}
  #   it "returns true" do
  #     subject.client!
  #     expect(User.client_logged_in?).to be_truthy
  #   end
  # end

  # describe ".belongs_to_client_account" do
  #   subject{create(:users)}
  #   let(:client_account){create(:client_account)}
  #   it "checks whether user object is associated with client account id" do
  #     subject.client_accounts << client_account
  #     subject.belongs_to_client_account(client_account.id)
  #     expect(subject.client_accounts).to include(client_account.id)
  #   end
  # end 

  describe ".blocked_path_list" do
    let!(:user_access_role){create(:user_access_role)}
    subject{create(:user, user_access_role_id: user_access_role.id)}
    it "returns blocked path list" do
      allow_any_instance_of(User).to receive(:get_blocked_path_list).and_return(user_access_role.id)
      expect(subject.blocked_path_list).to eq(1)
    end
  end
  
  describe "#find_for_database_authentication" do
    it " " do
    end
  end

  describe ".is_official?" do
    context "when role is admin" do
      it "returns true" do
        subject.admin!
        expect(subject.is_official?).to be_truthy
      end
    end

    context "when role is employee" do
      it "returns true" do
        subject.employee!
        expect(subject.is_official?).to be_truthy
      end
    end
  end

  describe ".name_for_user" do
    context "when email is present" do
      it "returns email" do
        subject.email = "test@gmail.com"
        expect(subject.name_for_user).to eq("test@gmail.com")
      end
    end

     context "when username is present" do
      it "returns username" do
        subject.email = nil
        subject.username = "danphe"
        expect(subject.name_for_user).to eq("danphe")
      end
    end
  end

end