require "test_helper"

class CertificatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @certificate = certificates(:one)
  end

  test "should get index" do
    get certificates_url
    assert_response :success
  end

  test "should get new" do
    get new_certificate_url
    assert_response :success
  end

  test "should create certificate" do
    assert_difference("Certificate.count") do
      post certificates_url, params: { certificate: { datacontact_id: @certificate.datacontact_id, enrollment_id: @certificate.enrollment_id, expires_at: @certificate.expires_at, issued_at: @certificate.issued_at, issued_by_enrollment_id: @certificate.issued_by_enrollment_id, journey_id: @certificate.journey_id, lead_id: @certificate.lead_id, meta: @certificate.meta, role_name: @certificate.role_name, service_id: @certificate.service_id, status: @certificate.status, taxbranch_id: @certificate.taxbranch_id } }
    end

    assert_redirected_to certificate_url(Certificate.last)
  end

  test "should show certificate" do
    get certificate_url(@certificate)
    assert_response :success
  end

  test "should get edit" do
    get edit_certificate_url(@certificate)
    assert_response :success
  end

  test "should update certificate" do
    patch certificate_url(@certificate), params: { certificate: { datacontact_id: @certificate.datacontact_id, enrollment_id: @certificate.enrollment_id, expires_at: @certificate.expires_at, issued_at: @certificate.issued_at, issued_by_enrollment_id: @certificate.issued_by_enrollment_id, journey_id: @certificate.journey_id, lead_id: @certificate.lead_id, meta: @certificate.meta, role_name: @certificate.role_name, service_id: @certificate.service_id, status: @certificate.status, taxbranch_id: @certificate.taxbranch_id } }
    assert_redirected_to certificate_url(@certificate)
  end

  test "should destroy certificate" do
    assert_difference("Certificate.count", -1) do
      delete certificate_url(@certificate)
    end

    assert_redirected_to certificates_url
  end
end
