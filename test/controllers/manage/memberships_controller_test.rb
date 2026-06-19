require "test_helper"

class Manage::MembershipsControllerTest < ActionDispatch::IntegrationTest
  test "Organizer は speaker メンバーを追加できること" do
    organizer = create(:user, :organizer)
    conference = create(:conference)
    create(:conference_membership, user: organizer, conference: conference, role: :organizer)

    sign_in_as(organizer)

    assert_difference "ConferenceMembership.count", 1 do
      post conference_manage_memberships_path(conference), params: {
        conference_membership: {
          role: "speaker",
          email_address: "speaker-new@example.com",
          name: "Speaker New"
        }
      }
    end

    assert_redirected_to conference_manage_memberships_path(conference)
  end
end
