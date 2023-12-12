---
layout: wiki
title: Weather Framework
description: Explains how to work with ACE3 weather system.
group: framework
order: 5
parent: wiki
mod: ace
version:
  major: 3
  minor: 0
  patch: 0
---

## 1. Overview

ACE3 Weather extends the existing weather by temperature, humidity and air pressure according to the geographic location, season and time of day.

The additional wind simulation, which is also influenced by the season and the geographical location, can be deactivated if necessary.

Cloud cover, rain and fog can still be set via the mission settings.


## 2. Wind Simulation

## 2.1 Temporarily Pause Wind Simulation

When Wind Simulation is enabled at mission start, it can be temporarily disabled by setting `ace_weather_disableWindSimulation = true`. To reenable wind simulation, the variable must either be set to `false` or `nil`.