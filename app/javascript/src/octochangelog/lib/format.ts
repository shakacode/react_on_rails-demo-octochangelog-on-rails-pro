import semver from "semver";

import type { GithubRelease } from "./types";

const HIGH_PRIORITY_GROUPS = ["breaking changes", "features", "bug fixes"] as const;
const LOW_PRIORITY_GROUPS = ["others", "credits", "thanks", "artifacts"] as const;

export function buildAuthStartPath(
  basePath: string,
  params: { from?: string; repo?: string; to?: string },
): string {
  const url = new URL(basePath, "http://ror.local");

  Object.entries(params).forEach(([key, value]) => {
    if (value) {
      url.searchParams.set(key, value);
    }
  });

  return `${url.pathname}${url.search}`;
}

export function compareGroupKeys(left: string, right: string): number {
  const leftPriority = groupPriority(left);
  const rightPriority = groupPriority(right);

  if (leftPriority !== rightPriority) {
    return leftPriority - rightPriority;
  }

  if (leftPriority === 0) {
    return left.localeCompare(right);
  }

  const reference = leftPriority === -1 ? HIGH_PRIORITY_GROUPS : LOW_PRIORITY_GROUPS;
  return reference.indexOf(left as (typeof reference)[number]) - reference.indexOf(right as (typeof reference)[number]);
}

export function compareReleasesByVersion(
  left: GithubRelease,
  right: GithubRelease,
  order: "asc" | "desc" = "desc",
): number {
  const leftVersion = extractVersionFromTag(left.tagName);
  const rightVersion = extractVersionFromTag(right.tagName);

  if (semver.valid(leftVersion) && semver.valid(rightVersion)) {
    return order === "desc" ? semver.rcompare(leftVersion, rightVersion) : semver.compare(leftVersion, rightVersion);
  }

  return 0;
}

export function displayGroupTitle(groupKey: string, originalTitle?: string): string {
  if (groupKey === "others") {
    return "Other notes";
  }

  if (originalTitle && sanitizeGroupTitle(originalTitle) !== groupKey) {
    return stripEmojis(originalTitle).trim();
  }

  return groupKey.replace(/\b\w/g, (character) => character.toUpperCase());
}

export function extractVersionFromTag(tagName: string): string {
  const candidate = tagName.split("/").at(-1) ?? tagName;
  return semver.coerce(candidate)?.version ?? candidate.replace(/^v/, "");
}

export function formatCompactNumber(value: number): string {
  return new Intl.NumberFormat("en-US", {
    maximumFractionDigits: 1,
    notation: "compact",
  }).format(value);
}

export function formatReadableDate(value?: string | null): string | null {
  if (!value) {
    return null;
  }

  return new Intl.DateTimeFormat("en-US", {
    day: "numeric",
    month: "short",
    year: "numeric",
  }).format(new Date(value));
}

export function groupKeyForTitle(title: string): string {
  const normalized = sanitizeGroupTitle(title);

  if (/(feature|minor)/i.test(normalized)) {
    return "features";
  }

  if (/(breaking.*change|major)/i.test(normalized)) {
    return "breaking changes";
  }

  if (/(bug|fix|patch)/i.test(normalized)) {
    return "bug fixes";
  }

  if (/thank/i.test(normalized)) {
    return "thanks";
  }

  if (/artifact/i.test(normalized)) {
    return "artifacts";
  }

  if (/credit/i.test(normalized)) {
    return "credits";
  }

  return normalized || "others";
}

export function isRepositorySlug(value: string): boolean {
  return /^[A-Za-z0-9_.-]+\/[A-Za-z0-9_.-]+$/.test(value.trim());
}

export function sanitizeGroupTitle(value: string): string {
  return stripEmojis(value).toLowerCase().replace(/\s+/g, " ").trim();
}

export function slugify(value: string): string {
  return value
    .normalize("NFKD")
    .replace(/[^\w\s-]/g, "")
    .trim()
    .toLowerCase()
    .replace(/[\s_-]+/g, "-");
}

export function stripEmojis(value: string): string {
  return value.replace(/\p{Extended_Pictographic}/gu, "");
}

function groupPriority(groupKey: string): -1 | 0 | 1 {
  if (HIGH_PRIORITY_GROUPS.includes(groupKey as (typeof HIGH_PRIORITY_GROUPS)[number])) {
    return -1;
  }

  if (LOW_PRIORITY_GROUPS.includes(groupKey as (typeof LOW_PRIORITY_GROUPS)[number])) {
    return 1;
  }

  return 0;
}
