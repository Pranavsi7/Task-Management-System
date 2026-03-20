import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import { PrismaClient } from '@prisma/client';
import { validationResult } from 'express-validator';
import {
  generateAccessToken,
  generateRefreshToken,
  verifyRefreshToken,
  revokeRefreshToken,
} from '../utils/jwt.utils';

const prisma = new PrismaClient();

export const register = async (req: Request, res: Response): Promise<void> => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    res.status(400).json({ errors: errors.array() });
    return;
  }

  const { email, password, name } = req.body;

  const existing = await prisma.user.findUnique({ where: { email } });
  if (existing) {
    res.status(409).json({ message: 'Email already in use' });
    return;
  }

  const passwordHash = await bcrypt.hash(password, 12);
  const user = await prisma.user.create({
    data: { email, name, passwordHash },
    select: { id: true, email: true, name: true, createdAt: true },
  });

  const accessToken = generateAccessToken({ userId: user.id, email: user.email });
  const refreshToken = await generateRefreshToken(user.id);

  res.status(201).json({ user, accessToken, refreshToken });
};

export const login = async (req: Request, res: Response): Promise<void> => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    res.status(400).json({ errors: errors.array() });
    return;
  }

  const { email, password } = req.body;

  const user = await prisma.user.findUnique({ where: { email } });
  if (!user) {
    res.status(401).json({ message: 'Invalid credentials' });
    return;
  }

  const valid = await bcrypt.compare(password, user.passwordHash);
  if (!valid) {
    res.status(401).json({ message: 'Invalid credentials' });
    return;
  }

  const accessToken = generateAccessToken({ userId: user.id, email: user.email });
  const refreshToken = await generateRefreshToken(user.id);

  res.json({
    user: { id: user.id, email: user.email, name: user.name, createdAt: user.createdAt },
    accessToken,
    refreshToken,
  });
};

export const refresh = async (req: Request, res: Response): Promise<void> => {
  const { refreshToken } = req.body;

  if (!refreshToken) {
    res.status(400).json({ message: 'Refresh token is required' });
    return;
  }

  const stored = await verifyRefreshToken(refreshToken);
  if (!stored) {
    res.status(401).json({ message: 'Invalid or expired refresh token' });
    return;
  }

  // Rotate refresh token
  await revokeRefreshToken(refreshToken);
  const newAccessToken = generateAccessToken({ userId: stored.userId, email: stored.user.email });
  const newRefreshToken = await generateRefreshToken(stored.userId);

  res.json({ accessToken: newAccessToken, refreshToken: newRefreshToken });
};

export const logout = async (req: Request, res: Response): Promise<void> => {
  const { refreshToken } = req.body;
  if (refreshToken) await revokeRefreshToken(refreshToken);
  res.json({ message: 'Logged out successfully' });
};
