export type FlashTone = "danger" | "success";

export interface FlashMessage {
  message: string;
  tone: FlashTone;
}

export interface FeaturedComparison {
  from: string;
  href: string;
  label: string;
  note: string;
  repo: string;
  to: string;
}

export interface RecentComparisonRun {
  createdAtLabel: string;
  fromVersion: string;
  href: string;
  id: number;
  repositoryFullName: string;
  toVersion: string;
}

export interface HomePageProps {
  comparePath: string;
  distinctRepositories: number;
  featuredComparisons: FeaturedComparison[];
  recentRuns: RecentComparisonRun[];
  sourceName: string;
  sourceUrl: string;
  totalComparisons: number;
}

export interface RepositorySearchResult {
  description?: string | null;
  fullName: string;
  htmlUrl: string;
  id: number;
  language?: string | null;
  stargazersCount?: number | null;
}

export interface ReleaseOption {
  id: number;
  name?: string | null;
  publishedAt?: string | null;
  tagName: string;
  url: string;
  version: string;
}

export interface GithubRelease {
  body?: string | null;
  id: number;
  name?: string | null;
  publishedAt?: string | null;
  tagName: string;
  url: string;
}

export interface RepositorySummary {
  fullName: string;
  htmlUrl: string;
  id: number;
  name: string;
  ownerLogin: string;
}

export interface ComparisonPayload {
  error: string | null;
  releases: GithubRelease[];
  repository: RepositorySummary | null;
  totalStableReleases: number;
}

export interface ComparePageProps {
  authEnabled: boolean;
  authenticated: boolean;
  comparePath: string;
  comparison?: ComparisonPayload | null;
  csrfToken: string;
  flash?: FlashMessage | null;
  from?: string | null;
  loginPathBase: string;
  logoutPath: string;
  releasesEndpoint: string;
  repo?: string | null;
  repositoriesEndpoint: string;
  to?: string | null;
}
