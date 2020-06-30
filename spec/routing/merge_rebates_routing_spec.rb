require "rails_helper"

RSpec.describe MergeRebatesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/merge_rebates").to route_to("merge_rebates#index")
    end

    it "routes to #new" do
      expect(:get => "/merge_rebates/new").to route_to("merge_rebates#new")
    end

    it "routes to #show" do
      expect(:get => "/merge_rebates/1").to route_to("merge_rebates#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/merge_rebates/1/edit").to route_to("merge_rebates#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/merge_rebates").to route_to("merge_rebates#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/merge_rebates/1").to route_to("merge_rebates#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/merge_rebates/1").to route_to("merge_rebates#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/merge_rebates/1").to route_to("merge_rebates#destroy", :id => "1")
    end

  end
end
