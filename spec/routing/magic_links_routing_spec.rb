require "rails_helper"

RSpec.describe MagicLinksController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/magic_links").to route_to("magic_links#index")
    end

    it "routes to #show" do
      expect(get: "/magic_links/1").to route_to("magic_links#show", id: "1")
    end


    it "routes to #create" do
      expect(post: "/magic_links").to route_to("magic_links#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/magic_links/1").to route_to("magic_links#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/magic_links/1").to route_to("magic_links#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/magic_links/1").to route_to("magic_links#destroy", id: "1")
    end
  end
end
