# frozen_string_literal: true

require "cases/helper"
require "models/person"

class ActiveModelI18nTests < ActiveModel::TestCase
  def setup
    I18n.backend = I18n::Backend::Simple.new
  end

  def teardown
    I18n.backend.reload!
  end

  def test_translated_model_attributes
    I18n.backend.store_translations "en", activemodel: { attributes: { person: {
      name: "person name attribute",
      "name=value": "person name value"
    } } }

    assert_equal "person name attribute", Person.human_attribute_name("name")
    assert_equal "person name value", Person.human_attribute_value("name", "value")
  end

  def test_translated_model_attributes_with_default
    I18n.backend.store_translations "en", attributes: {
      name: "name default attribute",
      "name=value": "name default value"
    }

    assert_equal "name default attribute", Person.human_attribute_name("name")
    assert_equal "name default value", Person.human_attribute_value("name", "value")
  end

  def test_translated_model_attributes_using_default_option
    assert_equal "name default attribute", Person.human_attribute_name("name", default: "name default attribute")
    assert_equal "name default value", Person.human_attribute_value("name", "value", default: "name default value")
  end

  def test_translated_model_attributes_using_default_option_as_symbol
    I18n.backend.store_translations "en", default_name: "name default attribute", default_gender: "gender default value"

    assert_equal "name default attribute", Person.human_attribute_name("name", default: :default_name)
    assert_equal "gender default value", Person.human_attribute_value("gender", "value", default: :default_gender)
  end

  def test_translated_model_attributes_falling_back_to_default
    assert_equal "Name", Person.human_attribute_name("name")
    assert_equal "", Person.human_attribute_value("name", nil)
  end

  def test_translated_model_attributes_using_default_option_as_symbol_and_falling_back_to_default
    assert_equal "Name", Person.human_attribute_name("name", default: :default_name)
    assert_equal "Value", Person.human_attribute_value("name", "value", default: :default_gender)
  end

  def test_translated_model_attributes_with_symbols
    I18n.backend.store_translations "en", activemodel: { attributes: { person: {
      name: "person name attribute",
      "name=value": "person name value"
    } } }

    assert_equal "person name attribute", Person.human_attribute_name(:name)
    assert_equal "person name value", Person.human_attribute_value(:name, :value)
  end

  def test_translated_model_attributes_with_ancestor
    I18n.backend.store_translations "en", activemodel: { attributes: { child: {
      name: "child name attribute",
      "name=value": "child name value"
    } } }

    assert_equal "child name attribute", Child.human_attribute_name("name")
    assert_equal "child name value", Child.human_attribute_value("name", "value")
  end

  def test_translated_model_attributes_with_ancestors_fallback
    I18n.backend.store_translations "en", activemodel: { attributes: { person: {
      name: "person name attribute",
      "name=value": "person name value"
    } } }

    assert_equal "person name attribute", Child.human_attribute_name("name")
    assert_equal "person name value", Child.human_attribute_value("name", "value")
  end

  def test_translated_model_attributes_with_attribute_matching_namespaced_model_name
    I18n.backend.store_translations "en", activemodel: { attributes: {
      person: { gender: "person gender attribute", "gender=value": "person gender value" },
      "person/gender": { attribute: "person/gender attribute", "attribute=value": "person/gender value" }
    } }

    assert_equal "person gender attribute", Person.human_attribute_name("gender")
    assert_equal "person gender value", Person.human_attribute_value("gender", "value")

    assert_equal "person/gender attribute", Person::Gender.human_attribute_name("attribute")
    assert_equal "person/gender value", Person::Gender.human_attribute_value("attribute", "value")
  end

  def test_translated_deeply_nested_model_attributes
    I18n.backend.store_translations "en", activemodel: { attributes: { "person/contacts/addresses": {
      street: "Deeply Nested Address Street attribute",
      "street=value": "Deeply Nested Address Street value"
    } } }

    assert_equal "Deeply Nested Address Street attribute", Person.human_attribute_name("contacts.addresses.street")
    assert_equal "Deeply Nested Address Street value", Person.human_attribute_value("contacts.addresses.street", "value")
  end

  def test_translated_nested_model_attributes
    I18n.backend.store_translations "en", activemodel: { attributes: { "person/addresses": {
      street: "Person Address Street attribute",
      "street=value": "Person Address Street value"
    } } }

    assert_equal "Person Address Street attribute", Person.human_attribute_name("addresses.street")
    assert_equal "Person Address Street value", Person.human_attribute_value("addresses.street", "value")
  end

  def test_translated_nested_model_attributes_with_namespace_fallback
    I18n.backend.store_translations "en", activemodel: { attributes: { addresses: {
      street: "Cool Address Street attribute",
      "street=value": "Cool Address Street value",
    } } }

    assert_equal "Cool Address Street attribute", Person.human_attribute_name("addresses.street")
    assert_equal "Cool Address Street value", Person.human_attribute_value("addresses.street", "value")
  end

  def test_translated_model_names
    I18n.backend.store_translations "en", activemodel: { models: { person: "person model" } }
    assert_equal "person model", Person.model_name.human
  end

  def test_translated_model_names_with_sti
    I18n.backend.store_translations "en", activemodel: { models: { child: "child model" } }
    assert_equal "child model", Child.model_name.human
  end

  def test_translated_model_with_namespace
    I18n.backend.store_translations "en", activemodel: { models: { 'person/gender': "gender model" } }
    assert_equal "gender model", Person::Gender.model_name.human
  end

  def test_translated_model_names_with_ancestors_fallback
    I18n.backend.store_translations "en", activemodel: { models: { person: "person model" } }
    assert_equal "person model", Child.model_name.human
  end

  def test_human_does_not_modify_options
    options = { default: "person model" }
    Person.model_name.human(options)
    assert_equal({ default: "person model" }, options)
  end

  def test_human_attribute_name_does_not_modify_options
    options = { default: "Cool gender" }

    Person.human_attribute_name("gender", options)
    assert_equal({ default: "Cool gender" }, options)

    Person.human_attribute_value("gender", nil, options)
    assert_equal({ default: "Cool gender" }, options)
  end
end
