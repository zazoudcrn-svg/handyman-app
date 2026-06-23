class AddBusinessWebsiteToContractorProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :contractor_profiles, :business_website, :string
  end
end
