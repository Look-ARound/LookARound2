## lookaround

Wherever you are, look around with AR to see recommended places to visit.

## Wireframes

<img src='https://user-images.githubusercontent.com/1326734/31310791-1c50c4c8-ab53-11e7-9ce8-8ce70c17859b.jpeg' title='Wireframe' width='400' alt=‘LookARound Wireframes’ />

## User Stories

Initial View: Augmented Reality
- [x] When user looks at what’s nearby them, they see recommended places available near them
- [x] The recommended places are the most popular among your friends and then the most popular among the public
- [ ] Callouts indicate why the places are recommended
- [x] Alternative view to see recommended places on a 2D map
- [ ] Alternative view to see recommended places in a list view

Filtering
- [x] User can choose a specific category they want to see
- [ ] Logged in users can toggle between popular-by-checkin and friends’ recommendations

Logging In
- [x] User can log in with a social media account to get places their friends/following celebs have visited

Place Detail
- [x] User can preview a POI to decide if they want to go: Show name, description, hours, photos, stats
- [x] User can see a 2D map of how to get from current location to that POI
- [x] User can see in AR how to get from current location to that POI
- [ ] Optional: User can "bookmark" POI as a place they want to visit
- [ ] Optional: User can “check in” to the POI when they get there
- [ ] Optional: User can see an optimized itinerary for the order to visit all POIs on a list

Lists
- [x] User taps on ‘+’ button to add place to list
- [x] User sees a table with lists created by them. They can select any of these to add the place to.
- [x] Users sees an ‘add new list’ button. User can select this if they want to create a new list with this place in it.
- [ ] User sees a checkmark next to the list name once the place has been added to the list
- [x] In Filters screen, user can see lists they have created
- [ ] User can drag left to delete a list
- [x] In Filters screen, user can view a list of public lists
- [x] Users can pick a list to display pins in that list
- [ ] Optional: User can share list of POIs with someone else with a deep link
- [ ] Optional: User can set privacy of list (private, friends only, public)

Optional: Marking a POI
- [ ] Optional: User can "Like" the place on Facebook to save a point of interest (POI) for others to discover
- [ ] Optional: User can add note to POI for others to view
- [ ] Optional: User can add photo, video to POI
- [ ] Optional: User can add tags (hashtags?) to POI for future filtering

Backend
- [x] Lists are stored in a Firebase database backend


## Video Walkthrough

Here's a walkthrough of implemented user stories:

<img src='lookaround-sprint1-1.gif' title='Sprint 1 Walkthrough' width='' alt='Sprint 1 Walkthrough Video' /> <img src='lookaround-sprint2-1.gif' title='Sprint 2 Walkthrough' width='' alt='Sprint 2 Walkthrough Video' />

GIFs created with [LiceCap](http://www.cockos.com/licecap/).

## Acknowledgements

Thanks to MapBox for their pre-release of the [MapBox + ARKit](https://github.com/mapbox/mapbox-arkit-ios) utilities. This accelerated our development and polished visuals for many of our mapping graphics.

Icons used from IconMonstr:
- [Location 3](https://iconmonstr.com/location-3/) for AR pins
- [Bookmark 1](https://iconmonstr.com/bookmark-1/) and [Bookmark 2](https://iconmonstr.com/bookmark-2/) for bookmark indicator

## License
  Copyright 2017 Ali Mir, Angela Yu, John Nguyen, and Siji Rachel Tom

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
