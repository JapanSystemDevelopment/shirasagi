FactoryGirl.define do
  factory :faq_node_base, class: Faq::Node::Base, traits: [:cms_node] do
    route "faq/base"
  end

  factory :faq_node_page, class: Faq::Node::Page, traits: [:cms_node] do
    route "faq/page"
  end
end
