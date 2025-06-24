# Routine Tracker

A Ruby on Rails application for tracking personal data and routines through customizable forms, with powerful analytics and visualization capabilities.

## Overview

Routine Tracker helps you collect, organize, and analyze personal data through structured surveys and forms. Whether you're tracking health metrics, daily habits, mood patterns, or any other routine data, this application provides the tools to capture information consistently and gain insights through metrics and dashboards.

> **Self-Hosted Only**: This is a personal data tracking application designed for self-hosting. I don't provide a hosted service and don't want your data - you run it yourself, you control your data completely.

## Core Concepts

### Data Collection Hierarchy

The application uses a hierarchical structure for organizing and collecting data:

```
Forms
├── Sections
    ├── Questions
        └── Answers (stored in Responses)
```

#### **Forms**
- Top-level containers that group related sections
- Represent complete surveys or data collection sessions
- Can be filled out multiple times to create different responses
- Support draft functionality for partial completion across sessions

#### **Sections** 
- Logical groupings of related questions within a form
- Help organize complex forms into manageable chunks
- Can be reused across multiple forms

#### **Questions**
- Individual data points you want to collect
- Can be answered within forms OR standalone for quick data entry
- Support multiple types:
  - **String**: Text input
  - **Number**: Numeric input
  - **Bool**: Yes/No checkbox
  - **Range**: Dropdown with predefined options (min/max values)
- **Flexible Usage**: Use forms for structured data collection, or answer questions directly when forms feel too heavyweight

#### **Responses & Answers**
- **Response**: A complete form submission session
- **Answer**: Individual question responses within a response
- Each answer stores the actual data value based on question type

### Analytics & Visualization

#### **Metrics**
Transform raw answer data into meaningful analytics:

- **Functions**:
  - `answer`: Direct values from question responses
  - `sum`: Add values from multiple metrics
  - `average`: Average values from multiple metrics  
  - `difference`: Subtract metrics from each other
  - `count`: Count non-zero values

- **Time Resolution**: 
  - `five_minute`, `hour`, `day`, `week`, `month`

- **Time Width**:
  - `daily`, `weekly`, `monthly`, `90_days`, `yearly`, `all_time`

- **Wrap Functionality**: Overlay data by time patterns
  - `none`: Standard timeline view
  - `hour`: Show patterns within an hour (0-59 minutes)
  - `day`: Show patterns within a day (00:00-23:59)  
  - `weekly`: Show patterns within a week

#### **Dashboards**
Customizable views that can display:
- Metrics with time-series visualizations
- Quick-access question answering
- Links to forms for easy data entry

#### **Alerts**
Automated notifications based on metric thresholds to help you stay on track with your routines.

### Organization

#### **Namespaces**
Hierarchical organization system (e.g., `health.fitness`, `home.chores`) that helps categorize and filter all entities for better organization.

#### **Users**
Multi-user support with data isolation - each user sees only their own forms, responses, and metrics.

## Key Features

### 🚀 **Flexible Data Entry**
- **Structured Forms**: Complete surveys with multiple sections and auto-save drafts
- **Quick Questions**: Answer individual questions directly when forms are overkill
- **Cross-device Sync**: Continue forms on any device where you're logged in
- **Flexible Question Types**: String, number, boolean, and range inputs
- **Reusable Components**: Share sections across multiple forms

### 📊 **Powerful Analytics** 
- **Time-series Visualization**: See trends and patterns over time
- **Flexible Aggregation**: Sum, average, count, and compare metrics
- **Pattern Recognition**: Wrap functionality reveals daily/weekly patterns
- **Multi-resolution Analysis**: From 5-minute intervals to monthly trends

### 📈 **Interactive Dashboards**
- **Custom Views**: Create personalized dashboards for different use cases
- **Mixed Content**: Combine metrics, quick questions, and form links
- **Real-time Updates**: See your latest data immediately

### 🔔 **Smart Alerts**
- **Threshold Monitoring**: Get notified when metrics cross important values
- **Routine Reminders**: Stay consistent with your tracking habits

## Example Use Cases

### Health & Fitness Tracking
```
Form: "Daily Health Check"
├── Section: "Physical Metrics"
│   ├── Weight (number)
│   ├── Sleep Hours (number)
│   └── Exercise (bool)
└── Section: "Mental Wellness"
    ├── Mood (range: 1-10)
    ├── Stress Level (range: 1-5)
    └── Meditation (bool)
```

**Metrics Examples:**
- Average daily weight with `wrap: "none"` to see weight trends
- Sleep patterns with `resolution: "day"`, `wrap: "weekly"` to see which days you sleep best
- Exercise consistency with `function: "count"` to track workout frequency

### Home Management
```
Form: "Household Tasks"
├── Section: "Maintenance"
│   ├── Cleaned Kitchen (bool)
│   ├── Watered Plants (bool)
│   └── Checked Mail (bool)
└── Section: "Utilities"
    ├── Water Pressure (range: 1-10)
    ├── Temperature (number)
    └── Energy Usage (number)
```

**Dashboard Setup:**
- Quick daily task checkboxes (answer questions directly)
- Water pressure trend metric
- Link to weekly deep-cleaning form

## Getting Started

### Prerequisites
- Ruby 3.x
- Rails 8.x
- SQLite (development) or PostgreSQL (production)

### Installation

1. **Clone the repository**
   ```bash
   git clone git@github.com:josephburnett/routine.git
   cd routine
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Setup database**
   ```bash
   rails db:create
   rails db:migrate
   ```

4. **Start the server**
   ```bash
   rails server
   ```

5. **Visit the application**
   Open your browser to `http://localhost:3000`

### Production Deployment

The application is deployed using [Kamal](https://kamal-deploy.org/) to a local network machine (`home.local`). This setup provides a self-hosted solution accessible within your local network while maintaining complete data privacy and control.

### Quick Start Guide

1. **Create your first form**
   - Navigate to Forms → New Form
   - Add sections and questions
   - Organize with namespaces (e.g., `health`, `home.maintenance`)

2. **Fill out the form**
   - Use the "Survey" link to fill out your form
   - Drafts save automatically as you type
   - Submit when complete

3. **Create metrics**
   - Navigate to Metrics → New Metric
   - Choose questions to analyze
   - Set time resolution and width
   - Experiment with wrap settings for pattern analysis

4. **Build a dashboard**
   - Navigate to Dashboards → New Dashboard
   - Add your metrics for visualization
   - Include quick-access questions for lightweight data entry
   - Add form links for structured data collection

## Technical Architecture

### Models & Relationships

```ruby
User
├── has_many :forms
├── has_many :sections  
├── has_many :questions
├── has_many :responses
├── has_many :answers
├── has_many :metrics
├── has_many :dashboards
└── has_many :form_drafts

Form
├── belongs_to :user
├── has_and_belongs_to_many :sections
├── has_many :responses
└── has_many :form_drafts

Response
├── belongs_to :user
├── belongs_to :form
└── has_many :answers

Metric
├── belongs_to :user
├── has_many :questions (for 'answer' function)
├── has_many :child_metrics (for calculated functions)
└── belongs_to :first_metric (for 'difference' function)
```

### Key Technologies

- **Backend**: Ruby on Rails 8 with Turbo for seamless navigation
- **Frontend**: ERB templates with vanilla JavaScript
- **Database**: SQLite (development), PostgreSQL ready
- **Visualization**: Chart.js for time-series plotting
- **Styling**: CSS custom properties with clean, responsive design

### Data Storage

- **Structured Data**: Traditional Rails models for forms, questions, responses
- **Draft Data**: JSON fields for flexible form state storage
- **Time Series**: Optimized queries for metric calculations across time ranges
- **Namespacing**: Hierarchical organization without complex tree structures

## Contributing

This is a personal project, but the codebase demonstrates:

- Clean Rails architecture patterns
- Flexible data modeling for user-generated content
- Time-series data handling and visualization
- Auto-save functionality with Turbo integration
- Multi-dimensional analytics (functions, time, patterns)

## License

MIT License

Copyright (c) 2025 Joseph Burnett

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---

**Built for tracking the patterns that matter to you.**