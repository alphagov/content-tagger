namespace :taxonomy do
  namespace :ordered_related_items_overrides do
    desc "Copies all ordered related items to ordered related item overrides for selected mainstream pages"
    task populate: :environment do
      mainstream_content_with_curated_sidebar = [
        "/nhs-bursaries",
        "/student-finance-register-login",
        "/dance-drama-awards",
        "/teacher-training-funding",
        "/student-finance-for-existing-students",
        "/funding-for-postgraduate-study",
        "/apply-online-for-student-finance",
        "/extra-money-pay-university",
        "/career-development-loans",
        "/travel-grants-students-england",
        "/parents-learning-allowance",
        "/social-work-bursaries",
        "/adult-dependants-grant",
        "/disabled-students-allowances-dsas",
        "/apply-for-student-finance",
        "/childcare-grant",
        "/postgraduate-loan",
        "/contact-student-finance-england",
        "/repaying-your-student-loan",
        "/student-finance",
        "/care-to-learn",
        "/advanced-learner-loan",
        "/student-finance-calculator",
        "/student-finance-forms",
      ]

      mainstream_content_with_curated_sidebar.each do |base_path|
        puts "Copying related items to related item overrides for #{base_path}"

        content_id =
          Services.publishing_api.lookup_content_id(base_path: base_path)
        content_item = ContentItem.find!(content_id)

        ordered_related_items = content_item.link_set.ordered_related_items
        link_content_ids =
          ordered_related_items.map { |item| item['content_id'] }

        updated_links = {
          ordered_related_items_overrides: link_content_ids
        }

        Services.publishing_api.patch_links(
          content_id,
          links: updated_links,
          previous_version: content_item.link_set.previous_version
        )
      end
    end
  end
end
