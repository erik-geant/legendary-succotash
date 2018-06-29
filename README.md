# GÉANT Ruby assessment questions

## Discussion

1. Describe how to release a rails application.
   * What are gems?
   * What about migrations?
   * Describe gem versions.
2. What are `rvm`, `rbenv` and `bundler`?
3. What is the result of the following expression?
   ```ruby
   (1..5).reduce &:+
    ```
4. Discuss the difference between the following three expressions:
    ```ruby
    f = lambda { |a, b| (a..b).reduce &:+ }

    f = Proc.new { |a, b| (a..b).reduce &:+ }

    def f(a,b)
      return (a..b).reduce &:+
    end
    ```

## Written exercises

5. Write a method that accepts an array as input and
   returns an array containing all prime integers
   from the input array.

6. Please do a code review of the
   file `reports_controller.rb` in this repository.

7. 