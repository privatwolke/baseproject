main = require "../src/scripts/main"

describe "test suite", ->
	it "should say hello", ->
		expect(main.hello("developer")).toBe("Hello, developer!")
