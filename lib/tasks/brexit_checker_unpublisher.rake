namespace :brexit_checker do
  desc "Unpublish the brexit checker and redirect to new slugs"
  task unpublish: [:environment] do
    BrexitCheckerUnpublisher.call
  end
end

class BrexitCheckerUnpublisher
  def self.list
    [{
       content_id: "1102fd2b-7b29-43f5-889b-3e781e09971f",
       new_base_path: "/transition-check/questions",
       old_base_path: "/get-ready-brexit-check/questions",
     },
     {
       content_id: "2c73a7e4-2473-4215-8257-04ebe73ca1bc",
       new_base_path: "/transition-check/results",
       old_base_path: "/get-ready-brexit-check/results",
     },
     {
       content_id: "0593033b-f713-41c5-bc67-90545091805c",
       new_base_path: "/transition-check/email-signup",
       old_base_path: "/get-ready-brexit-check/email-signup",
     }]
  end

  def self.call
    list.each do |to_unpublish|
      Services.publishing_api.unpublish(to_unpublish[:content_id],
                                        type: "redirect",
                                        allow_draft: false,
                                        redirects: [{
                                                      path: to_unpublish[:old_base_path],
                                                      type: "exact",
                                                      segments_mode: "preserve",
                                                      destination: to_unpublish[:new_base_path],
                                                    }])
    end
  end
end
