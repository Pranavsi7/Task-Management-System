import { Router } from 'express';
import { body } from 'express-validator';
import { authenticate } from '../middleware/auth.middleware';
import { getTasks, getTask, createTask, updateTask, deleteTask, toggleTask } from '../controllers/task.controller';

const router = Router();

router.use(authenticate);

router.get('/', getTasks);
router.post('/', [
  body('title').trim().notEmpty().withMessage('Title is required'),
  body('priority').optional().isIn(['LOW', 'MEDIUM', 'HIGH']),
  body('dueDate').optional().isISO8601(),
], createTask);

router.get('/:id', getTask);
router.patch('/:id', [
  body('title').optional().trim().notEmpty(),
  body('status').optional().isIn(['PENDING', 'IN_PROGRESS', 'COMPLETED']),
  body('priority').optional().isIn(['LOW', 'MEDIUM', 'HIGH']),
  body('dueDate').optional().isISO8601(),
], updateTask);
router.delete('/:id', deleteTask);
router.patch('/:id/toggle', toggleTask);

export default router;
