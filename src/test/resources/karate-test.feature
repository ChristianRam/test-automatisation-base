@REQ_MARVEL-001 @HU001 @crud_characters @marvel_characters_api @Agente2 @E2 @iniciativa_marvel
Feature: Test de API de personajes Marvel

  Background:
    * configure ssl = true
    * url 'http://bp-se-test-cabcd9b246a5.herokuapp.com'
    * path '/csramire/api/characters'
    * def headers = {"Content-Type": "application/json"}
    * headers headers
    * def generarPersonaje =
    """
    function() {
      return {
        "name": "Wonderwoman-" + java.util.UUID.randomUUID().toString().substring(0, 8),
        "alterego": "Diana Prince",
        "description": "Amazonian princess",
        "powers": ["Super strength", "Lasso of Truth"]
      }
    }
    """
    * def personajeData = callonce generarPersonaje
    * def crearPersonajeInline =
    """
    function() {
      var tempUrl = 'http://bp-se-test-cabcd9b246a5.herokuapp.com/csramire/api/characters';
      var result = karate.call('classpath:crear-personaje-inline.feature', { url: tempUrl, data: personajeData });
      return { id: result.response.id };
    }
    """
    * def characterId = callonce crearPersonajeInline
    * print 'ID del personaje creado:', characterId.id

  @id:1 @ObtenerTodosPersonajes
  Scenario: T-API-MARVEL-001-CA01-Obtener todos los personajes exitosamente
    When method GET
    Then status 200
    * print response
    And match response != null
    And match response == '#array'

  @id:2 @ObtenerPersonajePorId
  Scenario: T-API-MARVEL-001-CA02-Obtener personaje por ID exitosamente
    * path characterId.id
    When method GET
    Then status 200
    And match response != null
    And match response.id == characterId.id

  @id:3 @obtenerPersonajePorIdInexistente
  Scenario: T-API-MARVEL-001-CA03-Obtener personaje por ID inexistente
    * path '999'
    When method GET
    Then status 404
    And match response != null
    And match response.error == "Character not found"

  @id:4 @crearPersonaje
  Scenario: T-API-MARVEL-001-CA04-Crear personaje exitosamente
    * def jsonData = personajeData
    And request jsonData
    When method POST
    Then status 201
    And match response != null
    And match response.id != null

  @id:5 @CrearPersonajeNombreDuplicado
  Scenario: T-API-MARVEL-001-CA05-Crear personaje nombre duplicado
    * def jsonData =
      """
      {
        "name": "Iron Man",
        "alterego": "Tony Stark",
        "description": "Genius billionaire",
        "powers": ["Armor", "Flight"]
      }
      """
    And request jsonData
    When method POST
    Then status 400
    And match response != null
    And match response.error == "Character name already exists"

  @id:6 @CrearPersonajeCamposFaltantes
  Scenario: T-API-MARVEL-001-CA06-Crear personaje con campos faltantes
    * def jsonData =
      """
      {
        "name": "",
        "alterego": "",
        "description": "",
        "powers": []
      }
      """
    And request jsonData
    When method POST
    Then status 400
    And match response != null
    And match response.name == "Name is required"
    And match response.description == "Description is required"
    And match response.powers == "Powers are required"
    And match response.alterego == "Alterego is required"

  @id:7 @ActualizarPersonaje
  Scenario: T-API-MARVEL-001-CA07-Actualizar personaje exitosamente
    * path '1'
    * def jsonData =
      """
      {
        "name": "Iron Man",
        "alterego": "Tony Stark",
        "description": "Updated description",
        "powers": ["Armor", "Flight"]
      }
      """
    And request jsonData
    When method PUT
    Then status 200
    And match response != null
    And match response.description == "Updated description"

  @id:8 @ActualizarPersonajeNoExiste
  Scenario: T-API-MARVEL-001-CA08-Actualizar personaje que no existe
    * path '999'
    * def jsonData =
      """
      {
        "name": "Iron Man",
        "alterego": "Tony Stark",
        "description": "Updated description",
        "powers": ["Armor", "Flight"]
      }
      """
    And request jsonData
    When method PUT
    Then status 404
    And match response != null
    And match response.error == "Character not found"

  @id:9 @EliminarPersonaje
  Scenario: T-API-MARVEL-001-CA09-Eliminar personaje exitosamente
    * path characterId.id
    When method DELETE
    Then status 204
    And match response == ''
    And match responseStatus == 204

  @id:10 @EliminarPersonajeInexistente
  Scenario: T-API-MARVEL-001-CA10-Eliminar personaje inexistente
    * path '999'
    When method DELETE
    Then status 404
    And match response != null
    And match response.error == "Character not found"