# Tasks list

- [x] Change placeholder searchbar text to "Ask me a question"
- [x] Fix search results coming from stackoverflow API
- [x] Render search results properly on website. Should be accessible globally from anywhere
- [x] Each search result should be clickable - render it in our custom page
- [x] Recent 5 questions searched by a user should be cached in a database of your choice.
- [x] Ask AI functionality to generate AI answers for a stackoverflow question.
- [x] Display a ranking option for ranking search results by newest, oldest, stackoverflow scores, or LLM ranking (ask LLM for confidence scores out of 100).
- [x] Update GitHub repo readme.
- [x] Code cleanup
- [x] Dockerized deployment
- [x] Draw a nice architecture diagram (convert handwritten notes into a properly structured diagram)
- [x] UX improvement: Focus on a webpage element on page load. Based on German Velasco's suggestion, focus on the search bar on page load. Link: https://www.youtube.com/shorts/LUY9RE9HLQM

# Future tasks
- [ ] Respect user's local timezone
- [ ] Rate limiter for calling stackoverflow API + LLM API, have configurable rate limits. Use hammer (https://github.com/ExHammer/hammer) as a rate limiter rather than re-inventing the wheel
- [ ] Add documentation (using ExDoc)
- [ ] Structured JSON logging
- [ ] Code linter and security checker: credo + sobelow
- [ ] Setup CI
- [ ] Use LLM to generate good search questions + tags for search term. Show it as "Did you mean?" on the search results page.
- [ ] Best answer is a continuous effort, keep improving it by asking user feedback and adding that to LLM.
- [ ] Use Instructor library instead of ExOpenAI for getting structured responses from LLM. Instructor is a more generic library that can be used with any LLM model. Link: https://github.com/thmsmlr/instructor_ex