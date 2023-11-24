# GenAI

✨ Generative AI toolset for Ruby ✨

GenAI allows you to easily integrate Generative AI model providers like OpenAI, Google Vertex AI, Stability AI, etc. Easily add Large Language Models, Stable Diffusion image generation, and other AI model integrations into your application!

![Tests](https://github.com/alchaplinsky/gen-ai/actions/workflows/main.yml/badge.svg?branch=main)
[![Gem Version](https://badge.fury.io/rb/gen-ai.svg)](https://badge.fury.io/rb/gen-ai)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/alchaplinsky/gen-ai/blob/main/LICENSE.txt)

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add gen-ai

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install gen-ai

## Usage

Require it in you code:

```ruby
require 'gen_ai'
```

### Feature support

✅ - Supported | ❌ - Not supported | 🛠️ - Work in progress

Language models capabilities

| Provider         | Embedding | Completion | Conversation | Sentiment | Summarization |
| ---------------- | :-------: | :--------: | :----------: | :-------: | :-----------: |
| **OpenAI**       |    ✅     |     ✅     |      ✅      |    🛠️     |      🛠️       |
| **Google Palm2** |    ✅     |     ✅     |      ✅      |    🛠️     |      🛠️       |

Image generation model capabilities

| Provider        | Generate | Variations | Edit | Upscale |
| --------------- | :------: | :--------: | :--: | :-----: |
| **OpenAI**      |    ✅    |     ✅     |  ✅  |   ❌    |
| **StabilityAI** |    ✅    |     ❌     |  ✅  |   ✅    |

### Language

Instantiate a language model client by passing a provider name and an API token.

```ruby
model = GenAI::Language.new(:open_ai, ENV['OPEN_AI_TOKEN'])
```

Generate **embedding(s)** for text using provider/model that fits your needs

```ruby
result = model.embed('Hi, how are you?')
# => #<GenAI::Result:0x0000000110be6f20...>

result.value
# =>  [-0.013577374, 0.0021624255, 0.0019274801, ... ]

result = model.embed(['Hello', 'Bonjour', 'Cześć'])
# => #<GenAI::Result:0x0000000110be6f34...>

result.values
# =>  [[-0.021834826, -0.007176527, -0.02836839,, ... ], [...], [...]]
```

Generate text **completions** using Large Language Models

```ruby
result = model.complete('London is a ', temperature: 0, max_tokens: 11)
# => #<GenAI::Result:0x0000000110be6d21...>

result.value
# => "vibrant and diverse city located in the United Kingdom"


result = model.complete('London is a ', max_tokens: 12, n: 2)
# => #<GenAI::Result:0x0000000110c25c70...>

result.values
# => ["thriving, bustling city known for its rich history.", "major global city and the capital of the United Kingdom."]

```

Have a **conversation** with Large Language Model.

```ruby
result = model.chat('Hi, how are you?')
# = >#<GenAI::Result:0x0000000106ff3d20...>

result.value
# => "Hello! I'm an AI, so I don't have feelings, but I'm here to help. How can I assist you today?"

history = [
    {role: 'user', content: 'What is the capital of Great Britain?'},
    {role: 'assistant', content: 'London'},
]

result = model.chat("what about France?", history: history)
# => #<GenAI::Result:0x00000001033c3bc0...>

result.value
# => "Paris"
```

### Image

Instantiate a image generation model client by passing a provider name and an API token.

```ruby
model = GenAI::Image.new(:open_ai, ENV['OPEN_AI_TOKEN'])
```

Generate **image(s)** using provider/model that fits your needs

```ruby
result = model.generate('A painting of a dog')
# => #<GenAI::Result:0x0000000110be6f20...>

result.value
# => image binary

result.value(:base64)
# => image in base64

# Save image to file
File.open('dog.jpg', 'wb') do |f|
  f.write(result.value)
end
```

![dog](https://github.com/alchaplinsky/gen-ai/assets/695947/27a2af5d-530b-4966-94e8-6cdf628b6cac)

Get more **variations** of the same image

```ruby
result = model.variations('./dog.jpg')
# => #<GenAI::Result:0x0000000116a1ec50...>

result.value
# => image binary

result.value(:base64)
# => image in base64

# Save image to file
File.open('dog_variation.jpg', 'wb') do |f|
  f.write(result.value)
end

```

![dog_variation](https://github.com/alchaplinsky/gen-ai/assets/695947/977f5238-0114-4085-8e61-8f8b356ce308)

**Editing** existing images with additional prompt

```ruby
result = model.edit('./llama.jpg', 'A cute llama wearing a beret', mask: './mask.png')
# => #<GenAI::Result:0x0000000116a1ec50...>

result.value
# => image binary

result.value(:base64)
# => image in base64

# Save image to file
File.open('dog_edited.jpg', 'wb') do |f|
  f.write(result.value)
end
```

![llama](https://github.com/alchaplinsky/gen-ai/assets/695947/9c862c6c-428e-463c-b935-ca749a6a33df)
![llama_edited](https://github.com/alchaplinsky/gen-ai/assets/695947/070d8e6a-07a0-4ed2-826f-8b9aabd183ae)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/alchaplinsky/gen-ai. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/alchaplinsky/gen-ai/blob/main/CODE_OF_CONDUCT.md).

## Code of Conduct

Everyone interacting in the GenAI project's codebases, issue trackers, chat rooms, and mailing lists is expected to follow the [code of conduct](https://github.com/alchaplinsky/gen-ai/blob/main/CODE_OF_CONDUCT.md).
