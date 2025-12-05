# GitHub Pages Deployment Guide

This guide explains how to deploy RBM-Pulse to GitHub Pages using GitHub Actions.

## Prerequisites

1. A GitHub repository with GitHub Pages enabled
2. Supabase project URL and anon key
3. Flutter SDK installed (for local testing)

## Setup Instructions

### 1. Enable GitHub Pages

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Pages**
3. Under **Source**, select **GitHub Actions**
4. Save the settings

### 2. Configure GitHub Secrets

You need to add your Supabase credentials as GitHub Secrets:

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add the following secrets:
   - **Name**: `SUPABASE_URL`
     - **Value**: Your Supabase project URL (e.g., `https://xxxxx.supabase.co`)
   - **Name**: `SUPABASE_ANON_KEY`
     - **Value**: Your Supabase anon/public key

### 3. Automatic Deployment

Once configured, the app will automatically deploy to GitHub Pages when you:
- Push to the `main` or `master` branch
- Manually trigger the workflow from the **Actions** tab

The deployment workflow will:
1. Checkout the code
2. Setup Flutter
3. Install dependencies
4. Build the web app with your Supabase credentials
5. Deploy to GitHub Pages

### 4. Manual Local Deployment

You can also build the app locally using the deployment script:

```bash
# Set environment variables
export SUPABASE_URL='https://your-project.supabase.co'
export SUPABASE_ANON_KEY='your-anon-key'

# Run the deployment script
./scripts/deploy.sh
```

The script will:
- Validate Flutter installation
- Check for required environment variables
- Clean previous builds
- Build the Flutter web app with proper configuration
- Output the build to `rbm_pulse/build/web`

### 5. Testing Locally

After building, you can test the app locally:

```bash
cd rbm_pulse/build/web
python3 -m http.server 8000
```

Then open `http://localhost:8000` in your browser.

## Custom Base Path

If your app is deployed to a subdirectory (e.g., `https://username.github.io/repo-name/`), set the `BASE_HREF` environment variable:

```bash
export BASE_HREF='/repo-name/'
./scripts/deploy.sh
```

Or update the GitHub Actions workflow to use the correct base href.

## Troubleshooting

### Build Fails with Missing Environment Variables

Make sure you've set the GitHub Secrets correctly:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

### App Shows Configuration Error

If the app shows an error about missing Supabase configuration:
1. Verify the secrets are set correctly in GitHub
2. Check the GitHub Actions logs to ensure the build used the correct `--dart-define` flags
3. Rebuild and redeploy

### GitHub Pages Shows 404

1. Ensure GitHub Pages is enabled and set to use **GitHub Actions** as the source
2. Check that the workflow completed successfully in the **Actions** tab
3. Wait a few minutes for GitHub Pages to update

## Environment Variables

The app uses `String.fromEnvironment` for web builds, which requires compile-time constants passed via `--dart-define` flags:

- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_ANON_KEY`: Your Supabase anonymous/public key

These are automatically injected during the GitHub Actions build process using your repository secrets.

## Workflow File

The deployment workflow is located at `.github/workflows/deploy.yml`. It:
- Runs on pushes to `main`/`master` branches
- Can be manually triggered
- Builds the Flutter web app with proper environment variables
- Deploys to GitHub Pages automatically

## Support

For issues or questions, please check:
- GitHub Actions logs in the **Actions** tab
- Flutter web deployment documentation
- Supabase documentation
