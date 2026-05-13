# CHECKLIST

## WEEK'S
1st -> User accounts and login page
2nd -> quiz generator

## add animated thingy for tutor?

## add file uploads for llms to eat
1. Hotwire can accept file uploads
2. Then the backend should eat only the texts <- add text extraction

## add quiz generator  (should I add json stuffs?)
1. Hotwire might need to fetch json from the ollama api

On set quiz, it might need to create exam_controller for another model that strictly accepts json(or other good thingy formats to gib it into the frontend?
And same functional of streaming data of a user sending chats, but instead it's a blob of json-questions that answers by the user, and the llm will check it.??

??? -> Can ollama inference two models at the same time?

## Add Unit tests
1. ping to the ollama api
2. check if it is the input field have prob

