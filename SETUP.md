# Strava MCP Server — Railway Deployment

## 1. Create Strava API Application

1. Go to https://www.strava.com/settings/api
2. Create a new application (or use existing)
3. Set the **Authorization Callback Domain** to your Railway URL domain
   (e.g. `strava-mcp-production.up.railway.app`)
4. Copy the **Client ID** and **Client Secret**

## 2. Deploy to Railway

```bash
# From this directory:
railway login
railway init          # Create new project, name it "strava-mcp"
railway up            # Deploy
```

After first deploy, grab your Railway URL from the dashboard.

## 3. Set Environment Variables in Railway

In Railway dashboard → your service → Variables:

```
STRAVA_CLIENT_ID=<from step 1>
STRAVA_CLIENT_SECRET=<from step 1>
STRAVA_MCP_BASE_URL=https://YOUR_RAILWAY_URL
STRAVA_MCP_HOST=0.0.0.0
STRAVA_MCP_PORT=8000
```

## 4. Update Strava API App

Go back to https://www.strava.com/settings/api and set the Authorization Callback Domain to your Railway domain (without https://, just the domain):
```
strava-mcp-production.up.railway.app
```

## 5. Add to Claude.ai

The MCP URL to paste into Claude.ai → Settings → Connectors → Add custom connector:
```
https://YOUR_RAILWAY_URL/mcp
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

- **OAuth flow**: The server handles OAuth automatically via FastMCP. When Claude.ai connects, it will redirect you to Strava to authorize. This is a per-user flow.
- **Token refresh**: Handled automatically. Strava access tokens expire after 6 hours but are auto-refreshed using the refresh token.
- **Session storage**: In-memory by default (resets on redeploy). You'll need to re-authorize after each deploy. Fine for race week.
- **Activity filtering**: Supports distance names ("marathon", "half"), ranges ("5km:10km"), title search, and race detection.
