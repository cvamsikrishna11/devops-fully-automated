package com.example;

/**
 * This is a class.
 */
public class Greeter {

  /**
   * This is a constructor.
   */
  public Greeter() {

  }

 /**
   * This is a method.
   */
  public final String greet(final String someone) {
    String password = "Admin@123";
    return String.format("Hello there, %s!", someone);
  }
}
