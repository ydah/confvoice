require "test_helper"

class SecurityHeadersTest < ActionDispatch::IntegrationTest
  test "Content Security Policy header is present" do
    get root_path

    assert_response :success
    assert_includes response.headers["Content-Security-Policy"], "object-src 'none'"
    assert_includes response.headers["Content-Security-Policy"], "frame-ancestors 'none'"
    assert_includes response.headers["Content-Security-Policy"], "script-src 'self' https://www.gstatic.com"
    assert_no_match(/script-src[^;]*https:($|[ ;])/, response.headers["Content-Security-Policy"])
  end
end
