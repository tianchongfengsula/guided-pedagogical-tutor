# A Guided Pedagogical Tutor.

## Running localy
Prerequisites
For linux and MacOS users:
Git, Ollama, Rails
For Windows users:
WSL, Git, Ollama, Rails

1. Clone the repo
```sh
https://github.com/tianchongfengsula/guided-pedagogical-tutor.git && cd guided-pedagogical-tutor
```

2. Install rails
https://guides.rubyonrails.org/install_ruby_on_rails.html

3. Install Ollama
https://ollama.com/

3.1. Install the default model
```sh
ollama run lfm2.5-thinking
```
After you download the model enter `/bye` to close the model

4. Then Spawn another terminal then install dependencies
```sh
bundle install
```

5. Run
```sh
bin/dev
```
