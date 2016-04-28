task send_finder_links: [:environment] do
  # CMA cases.
  # [
  #   "/topic/competition/competition-act-cartels",
  #   "/topic/competition/consumer-protection",
  #   "/topic/competition/markets",
  #   "/topic/competition/mergers",
  #   "/topic/competition/regulatory-appeals-references"
  # ]
  Services.publishing_api.patch_links(
    "fef4ac7c-024a-4943-9f19-e85a8369a1f3",
    links: {
      topics: [
        "4a6f14ad-baa1-4b15-8026-8282913ef693",
        "65a89136-2117-41aa-ba96-35feb9d821f5",
        "1433d403-333f-4d81-b83a-c5358412fd1b",
        "7aa3ec0c-683e-44ba-aa3f-cc9655651b9b",
        "fd11e3b0-76bc-4197-b652-a030b57915be"
      ]
    }
  )

  # drug-safety-update
  # "medicines-medical-devices-blood/vigilance-safety-alerts"
  Services.publishing_api.patch_links(
    "602be505-4cf4-4f8c-8bfc-7bc4b63a7f47",
    links: {
      topics: ["3455b248-9237-40ac-ae9b-480a6a8ebd88"]
    }
  )

  # drug-device-alerts
  # ["/topic/medicines-medical-devices-blood/medical-devices-regulation-safety",
  # "/topic/medicines-medical-devices-blood/vigilance-safety-alerts"
  # ]
  Services.publishing_api.patch_links(
    "1e9c0ada-5f7e-43cc-a55f-cc32757edaa3",
    links: {
      topics: [
        "dd762ed5-abc8-4502-b4b4-3b51f9b7b0ca",
        "3455b248-9237-40ac-ae9b-480a6a8ebd88"
      ]
    }
  )
end
