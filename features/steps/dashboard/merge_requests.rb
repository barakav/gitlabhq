class Spinach::Features::DashboardMergeRequests < Spinach::FeatureSteps
  include SharedAuthentication
  include SharedPaths

  step 'I should see merge requests assigned to me' do
    should_see(assigned_merge_request)
    should_see(assigned_merge_request_from_fork)
    should_not_see(authored_merge_request)
    should_not_see(authored_merge_request_from_fork)
    should_not_see(other_merge_request)
  end

  step 'I should see merge requests authored by me' do
    should_see(authored_merge_request)
    should_see(authored_merge_request_from_fork)
    should_not_see(assigned_merge_request)
    should_not_see(assigned_merge_request_from_fork)
    should_not_see(other_merge_request)
  end

  step 'I should see all merge requests' do
    should_see(authored_merge_request)
    should_see(assigned_merge_request)
    should_see(other_merge_request)
  end

  step 'I have authored merge requests' do
    authored_merge_request
    authored_merge_request_from_fork
  end

  step 'I have assigned merge requests' do
    assigned_merge_request
    assigned_merge_request_from_fork
  end

  step 'I have other merge requests' do
    other_merge_request
  end

  step 'I click "Authored by me" link' do
    within ".assignee-filter" do
      click_link "Any"
    end
    within ".author-filter" do
      click_link current_user.name
    end
  end

  step 'I click "All" link' do
    within ".author-filter" do
      click_link "Any"
    end
    within ".assignee-filter" do
      click_link "Any"
    end
  end

  def should_see(merge_request)
    page.should have_content(merge_request.title[0..10])
  end

  def should_not_see(merge_request)
    page.should_not have_content(merge_request.title[0..10])
  end

  def assigned_merge_request
    @assigned_merge_request ||= create :merge_request,
                                  assignee: current_user,
                                  target_project: project,
                                  source_project: project
  end

  def authored_merge_request
    @authored_merge_request ||= create :merge_request,
                                  source_branch: 'simple_merge_request',
                                  author: current_user,
                                  target_project: project,
                                  source_project: project
  end

  def other_merge_request
    @other_merge_request ||= create :merge_request,
                              source_branch: '2_3_notes_fix',
                              target_project: project,
                              source_project: project
  end

  def authored_merge_request_from_fork
    @authored_merge_request_from_fork ||= create :merge_request,
                                            source_branch: 'basic_page',
                                            author: current_user,
                                            target_project: public_project,
                                            source_project: forked_project
  end

  def assigned_merge_request_from_fork
    @assigned_merge_request_from_fork ||= create :merge_request,
                                            source_branch: 'basic_page_fix',
                                            assignee: current_user,
                                            target_project: public_project,
                                            source_project: forked_project
  end

  def project
    @project ||= begin
                   project =create :project
                   project.team << [current_user, :master]
                   project
                 end
  end

  def public_project
    @public_project ||= create :project, :public
  end

  def forked_project
    @forked_project ||= Projects::ForkService.new(public_project, current_user).execute
  end
end
