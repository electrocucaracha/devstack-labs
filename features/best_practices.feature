Feature: Devstack instances should be deployed following the best practices
  In order to avoid deployment issues
  As stackers
  We'll use the OpenStack preference

Scenario: Ensure Ubuntu base image is used with libvirt provider
    Given I have libvirt_volume defined
    When it has source
    Then its value must contain ubuntu

Scenario: Ensure minimal RAM required
    Given I have libvirt_domain defined
    When it has memory
    Then its value must be greater than 4096
