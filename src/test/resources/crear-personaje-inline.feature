@ignore
Feature: Crear personaje para tests

  Scenario:
    * def uuid = function() { return java.util.UUID.randomUUID().toString().substring(0, 8) }
    * def uniqueData = __arg.data
    * set uniqueData.name = uniqueData.name + '-' + uuid()
    Given url __arg.url
    And request uniqueData
    And header Content-Type = 'application/json'
    When method POST
    Then status 201