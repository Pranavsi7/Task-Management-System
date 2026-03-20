import { Response } from 'express';
import { PrismaClient, TaskStatus } from '@prisma/client';
import { validationResult } from 'express-validator';
import { AuthRequest } from '../middleware/auth.middleware';

const prisma = new PrismaClient();

export const getTasks = async (req: AuthRequest, res: Response): Promise<void> => {
  const userId = req.user!.userId;
  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 10;
  const status = req.query.status as TaskStatus | undefined;
  const search = req.query.search as string | undefined;

  const where: Record<string, unknown> = { userId };
  if (status && Object.values(TaskStatus).includes(status)) where.status = status;
  if (search) where.title = { contains: search, mode: 'insensitive' };

  const [tasks, total] = await Promise.all([
    prisma.task.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      skip: (page - 1) * limit,
      take: limit,
    }),
    prisma.task.count({ where }),
  ]);

  res.json({ tasks, total, page, limit, totalPages: Math.ceil(total / limit) });
};

export const getTask = async (req: AuthRequest, res: Response): Promise<void> => {
  const task = await prisma.task.findFirst({
    where: { id: req.params.id, userId: req.user!.userId },
  });
  if (!task) { res.status(404).json({ message: 'Task not found' }); return; }
  res.json(task);
};

export const createTask = async (req: AuthRequest, res: Response): Promise<void> => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) { res.status(400).json({ errors: errors.array() }); return; }

  const { title, description, priority, dueDate } = req.body;
  const task = await prisma.task.create({
    data: { title, description, priority, dueDate: dueDate ? new Date(dueDate) : undefined, userId: req.user!.userId },
  });
  res.status(201).json(task);
};

export const updateTask = async (req: AuthRequest, res: Response): Promise<void> => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) { res.status(400).json({ errors: errors.array() }); return; }

  const existing = await prisma.task.findFirst({ where: { id: req.params.id, userId: req.user!.userId } });
  if (!existing) { res.status(404).json({ message: 'Task not found' }); return; }

  const { title, description, status, priority, dueDate } = req.body;
  const task = await prisma.task.update({
    where: { id: req.params.id },
    data: { title, description, status, priority, dueDate: dueDate ? new Date(dueDate) : undefined },
  });
  res.json(task);
};

export const deleteTask = async (req: AuthRequest, res: Response): Promise<void> => {
  const existing = await prisma.task.findFirst({ where: { id: req.params.id, userId: req.user!.userId } });
  if (!existing) { res.status(404).json({ message: 'Task not found' }); return; }

  await prisma.task.delete({ where: { id: req.params.id } });
  res.status(204).send();
};

export const toggleTask = async (req: AuthRequest, res: Response): Promise<void> => {
  const existing = await prisma.task.findFirst({ where: { id: req.params.id, userId: req.user!.userId } });
  if (!existing) { res.status(404).json({ message: 'Task not found' }); return; }

  const newStatus: TaskStatus = existing.status === TaskStatus.COMPLETED ? TaskStatus.PENDING : TaskStatus.COMPLETED;
  const task = await prisma.task.update({ where: { id: req.params.id }, data: { status: newStatus } });
  res.json(task);
};
