defmodule Recognizer do
  def get_element(items, index) do
    Enum.at(items, index)
  end

  def get_transformations(element, gram_rules) do
    gram_rules
    |> Enum.filter(fn rule -> rule[element] && true end)
    |> Enum.map(fn rule -> rule[element] end)
  end

  def substitute_in_chain(gram_rules, chain) do
    substitute_in_chain(gram_rules, chain, 0, [])
  end
  def substitute_in_chain(gram_rules, chain, index, substituted_chains) do
    if index == length(chain) do
      substituted_chains
    else
      # Getting the current index element
      curr_elem = get_element(chain, index)
      # Getting transformations
      curr_elem_transf = get_transformations(curr_elem, gram_rules);

      new_transf = curr_elem_transf
        |> Enum.map(fn trans -> Enum.concat([
          Enum.slice(chain, 0, index),
          trans,
          Enum.slice(chain, index+1..length(chain)-1)
        ]) end)

      new_subs_chain = Enum.concat(substituted_chains, new_transf)

      substitute_in_chain(gram_rules, chain, index + 1, new_subs_chain);
    end
  end

  def generate_chain(gram_rules, max_size) do
    generate_chain(gram_rules, max_size, 0, [["S"]])
  end
  def generate_chain(gram_rules, max_size, index, generated_chains) do
    # If there's no new generatedChains
    if index == length(generated_chains) do
      generated_chains
    else
      # Generating new chains
      generated_curr_chain = gram_rules
        |> substitute_in_chain(Enum.at(generated_chains, index))
        |> Enum.filter(fn chain -> length(chain) <= max_size end)
        |> Enum.filter(fn chain -> !Enum.member?(generated_chains, chain) end)
      # Adding to already generated chains list
      new_generated_chains = Enum.concat(generated_chains, generated_curr_chain)

      generate_chain(gram_rules, max_size, index + 1, new_generated_chains)
    end
  end

  def check_acceptance(chain, generated_chains) do
    generated_chains
    |> Enum.member?(chain)
  end

  def recognize_chain(gram_rules, chain) do
    max_size = length(chain)
    generated_chains = generate_chain(gram_rules, max_size)

    check_acceptance(chain, generated_chains)
  end
end
