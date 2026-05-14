# Strava MCP Server — Render Deployment

## 1. Create Strava API Application

1. Go to https://www.strava.com/settings/api
2. Create a new application (or use existing)
3. Set the **Authorization Callback Domain** to: `strava-mcp.onrender.com`
   (Update after first deploy if your Render URL differs)
4. Copy the **Client ID** and **Client Secret**

## 2. Deploy to Render

### Option A: Blueprint (one-click)
1. Push this repo to GitHub
2. Go to https://dashboard.render.com/blueprints
3. Click "New Blueprint Instance" → connect your GitHub repo
4. Render reads `render.yaml` and creates the service
5. Fill in the env vars when prompted

### Option B: Manual
1. Go to https://dashboard.render.com/
2. New → Web Service → Connect your GitHub repo
3. Set:
   - **Name**: `strava-mcp`
   - **Runtime**: Docker
   - **Plan**: Free
4. Add environment variables (see below)

## 3. Set Environment Variables

```
STRAVA_CLIENT_ID=<from step 1>
STRAVA_CLIENT_SECRET=<from step 1>
STRAVA_MCP_BASE_URL=https://strava-mcp.onrender.com
STRAVA_MCP_HOST=0.0.0.0
STRAVA_MCP_PORT=8000
```

## 4. Update Strava API App

Go back to https://www.strava.com/settings/api and set the Authorization Callback Domain to your Render domain (no https://, just the domain):
```
strava-mcp.onrender.com
```

## 5. Add to Claude.ai

The MCP URL to paste into Claude.ai → Settings → Connectors → Add custom connector:
```
https://strava-mcp.onrender.com/mcp
```

## Available Tools

| Tool | Description |
|------|-------------|
| `query_activities` | Query activities with filters (date, distance, type, race) |
| `get_athlete` | Profile, stats, training zones |
| `query_segments` | Search/explore segments |
| `star_segment` / `unstar_segment` | Star/unstar segments |
| `get_segment_leaderboard` | Segment leaderboard |
| `get_routes` / `get_route_details` | Route info |
| `export_route` | Export GPX/TCX |
| `analyze_training` | Training pattern analysis |
| `compare_activities` | Compare multiple activities |
| `find_similar_activities` | Find similar past activities |

## Notes

- **Free tier cold starts**: Render free services spin down after 15 min idle. First request after idle takes ~30-60 seconds.
- **OAuth flow**: The server handles OAuth automatically via FastMCP. When Claude.ai connects, it redirects you to Strava to authorize.
- **Token refresh**: Strava access tokens expire after 6 hours but are auto-refreshed. Session storage is in-memory (resets on redeploy/restart — you'll need to re-authorize).
- **Activity filtering**: Supports distance names ("marathon", "half"), ranges ("5km:10km"), title search, and race detection.
