/*
 * Structures
 */

class Error {


  /*
   * Getters and Setters
   */

  message { _message }

  type { _type }


  /*
   * Methods
   */

  construct new (message) {
    _message = message
    _type = null
  }


  construct new (message, type) {
    _message = message
    _type = type
  }


  construct throw (message) {
    Fiber.abort(message)
  }


  construct throw (message, type) {
    Fiber.abort(message)
  }


  throw () {
    Fiber.abort(_message)
  }


}
