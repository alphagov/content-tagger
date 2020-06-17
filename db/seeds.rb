if User.where(name: "Test user").none?
  gds_organisation_id = "af07d5a5-df63-4ddc-9383-6a666845ebe9"

  User.create!(
    uid: SecureRandom.uuid,
    name: "Test user",
    permissions: ["signin", "GDS Editor", "Tagathon participant"],
    organisation_content_id: gds_organisation_id,
  )
end
