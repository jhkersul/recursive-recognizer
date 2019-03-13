defmodule RecognizerTests do
  use ExUnit.Case
  doctest Recognizer

  test "should get the transformations" do
    elem = "S"
    gram_rules = [%{"S" => ["a"]}, %{"S" => ["a", "b", "c"]}]
    assert Recognizer.get_transformations(elem, gram_rules)
      == [["a"], ["a", "b", "c"]]
  end

  @tag subst_1: true
  test "should substitute in chain" do
    gram_rules = [
      %{ "S" => ["a", "A", "S"] },
      %{ "S" => ["a"] },
      %{ "A" => ["b", "a"] }
    ]
    assert Recognizer.substitute_in_chain(gram_rules, ["S", "A"])
      == [
        ["a", "A", "S", "A"],
        ["a", "A"],
        ["S", "b", "a"]
      ]
  end

  @tag subst_2: true
  test "should substitute in chain 2" do
    gram_rules = [
      %{ "S" =>  ["a", "A", "S"] },
      %{ "S" => ["a"] }
    ];

    assert Recognizer.substitute_in_chain(gram_rules, ["a", "A", "S"])
      == [
        ["a", "A", "a", "A", "S"],
        ["a", "A", "a"],
      ]
  end

  @tag generate_simple: true
  test "should generate a simple chain" do
    gram_rules = [
      %{ "S" => ["a"] }
    ]

    assert Recognizer.generate_chain(gram_rules, 2)
      == [
        ["S"],
        ["a"]
      ]
  end

  test "should generate a more complex chain" do
    gram_rules = [
      %{ "S" => ["a", "A", "S"] },
      %{ "S" => ["a"] }
    ]

    assert Recognizer.generate_chain(gram_rules, 3)
      == [
      ["S"],
      ["a", "A", "S"],
      ["a"],
      ["a", "A", "a"]
    ]
  end

  test "should accept a chain" do
    generated_chains = [
      ["S"],
      ["a", "A", "S"],
      ["a"],
      ["a", "b", "c", "d"]
    ]
    assert Recognizer.check_acceptance(["a"], generated_chains) == true
    assert Recognizer.check_acceptance(["a", "b", "c", "d"], generated_chains) == true
    assert Recognizer.check_acceptance(["a", "b", "c"], generated_chains) == false
    assert Recognizer.check_acceptance(["a", "b"], generated_chains) == false
  end

  test "should recognize chain" do
    gram_rules = [
      %{ "S" => ["a", "A", "S"] },
      %{ "S" => ["a"] },
      %{ "S" => ["S", "S"] },
      %{ "A" => ["b", "a"] },
      %{ "A" => ["S", "S"] }
    ]

    chain1 = ["a", "a"]
    assert Recognizer.recognize_chain(gram_rules, chain1) == true
    chain2 = ["a", "a", "a", "a"]
    assert Recognizer.recognize_chain(gram_rules, chain2) == true
    chain3 = ["b", "b"]
    assert Recognizer.recognize_chain(gram_rules, chain3) == false
  end
end
